import * as functions from 'firebase-functions';
import admin = require('firebase-admin');
import { DatabaseConstants } from './database-constants';
import {
  PrivateUserDataType,
  SessionInviteType,
  SessionMemberType,
  SessionType,
  UploadedSessionType,
  UserSessionType,
  UserType,
} from './types';

const firestore = admin.firestore();

exports.createSession = functions.https.onCall(async (req, res) => {
  console.log(`Creating session...`);

  if (res.auth?.uid === undefined) return;

  const creatorId: string = res.auth.uid;

  const result: UploadedSessionType = req as UploadedSessionType;

  const createdAt: Date = new Date();
  const endDate: Date = new Date();
  endDate.setDate(endDate.getDate() + 2);

  const session: SessionType = {
    campaign_id: result.campaign.id,
    campaign_img_url: result.campaign.image_url,
    campaign_name: result.campaign.title,
    campaign_short_description: result.campaign.short_description,
    session_name: result.session_name,
    session_description: result.session_description,
    current_amount: 0,
    amount_per_user: result.amount_per_user,
    created_at: admin.firestore.Timestamp.fromDate(createdAt),
    end_date: admin.firestore.Timestamp.fromDate(endDate),
    creator_id: creatorId,
  } as SessionType;

  // create Session
  const ref = await firestore
    .collection(DatabaseConstants.sessions)
    .add(session);

  // add creator to session members
  await ref
    .collection(DatabaseConstants.session_members)
    .doc(creatorId)
    .set({
      id: creatorId,
      donation_amount: 0,
    } as SessionMemberType);

  // add session to creator
  await firestore
    .collection(DatabaseConstants.user)
    .doc(creatorId)
    .collection(DatabaseConstants.sessions)
    .doc(ref.id)
    .set({
      id: ref.id,
      session_name: session.session_name,
      session_description: session.session_description,
      amount_per_user: session.amount_per_user,
      created_at: session.created_at,
      end_date: session.end_date,
      creator_id: session.creator_id,
      campaign_id: session.campaign_id,
    } as UserSessionType);

  const creatorUserInfo: UserType = (
    await firestore.collection(DatabaseConstants.user).doc(creatorId).get()
  ).data() as UserType;

  result.members.forEach(async (member) => {
    if (member.id) {
      // add to Session members with status invited
      await ref
        .collection(DatabaseConstants.session_invites)
        .doc(member.id)
        .set(
          {
            id: member.id,
          },
          { merge: true }
        );

      const memberDoc = firestore
        .collection(DatabaseConstants.user)
        .doc(member.id);

      // add to member to accept the invite
      await memberDoc
        .collection(DatabaseConstants.session_invites)
        .doc(ref.id)
        .set({
          id: ref.id,
          session_creator: creatorId,
          session_name: session.session_name,
          amount_per_user: session.amount_per_user,
          session_description: session.session_description,
        } as SessionInviteType);

      const privData: PrivateUserDataType = (
        await memberDoc
          .collection(DatabaseConstants.private_data)
          .doc(DatabaseConstants.data)
          .get()
      ).data() as PrivateUserDataType;

      console.log('Sending Pushmessages');

      if (
        privData.device_token !== null &&
        privData.device_token !== undefined
      ) {
        const payload = {
          notification: {
            title: 'Du wurdest zu einer Session eingeladen!',
            body: `${creatorUserInfo.name} hat dich zu der Session ${session.session_name} eingeladen.`,
          },
        };

        const pushRes = await admin
          .messaging()
          .sendToDevice(privData.device_token, payload);
        console.log(pushRes);
      }
    }
  });
});

exports.acceptInvite = functions.https.onCall(async (req, res) => {
  if (!res.auth) return;

  console.log('Accept Invite');

  const userId: string = res.auth?.uid;
  const invite: SessionInviteType = req as SessionInviteType;

  const userDoc = firestore.collection(DatabaseConstants.user).doc(userId);
  const sessionDoc = firestore
    .collection(DatabaseConstants.sessions)
    .doc(invite.id);

  // delete invite from user
  await userDoc
    .collection(DatabaseConstants.session_invites)
    .doc(invite.id)
    .delete();

  // create member access in session
  await sessionDoc
    .collection(DatabaseConstants.session_members)
    .doc(userId)
    .set({
      id: userId,
      donation_amount: 0,
    } as SessionMemberType);

  const session: SessionType = (await sessionDoc.get()).data() as SessionType;

  // create session in user doc
  await userDoc
    .collection(DatabaseConstants.sessions)
    .doc(invite.id)
    .set({
      id: invite.id,
      session_name: session.session_name,
      session_description: session.session_description,
      amount_per_user: session.amount_per_user,
      campaign_id: session.campaign_id,
      created_at: session.created_at,
      end_date: session.end_date,
      creator_id: session.creator_id,
    } as UserSessionType);
});

exports.declineInvite = functions.https.onCall(async (req, res) => {
  if (!res.auth) return;

  console.log('Decline Invite');

  const userId: string = res.auth?.uid;
  const invite: SessionInviteType = req as SessionInviteType;

  // delete invite from user
  await firestore
    .collection(DatabaseConstants.user)
    .doc(userId)
    .collection(DatabaseConstants.session_invites)
    .doc(invite.id)
    .delete();
});

exports.onDeleteSession = functions.firestore
  .document(`${DatabaseConstants.sessions}/{sessionId}`)
  .onDelete(async (snapshot, context) => {
    const sessionDocs = await firestore
      .collectionGroup(DatabaseConstants.sessions)
      .where(DatabaseConstants.id, '==', snapshot.id)
      .get();

    sessionDocs.forEach(async (doc) => await doc.ref.delete());

    const sessionInviteDocs = await firestore
      .collectionGroup(DatabaseConstants.session_invites)
      .where(DatabaseConstants.id, '==', snapshot.id)
      .get();

    sessionInviteDocs.forEach(async (doc) => await doc.ref.delete());

    const sessionMembers = await firestore
      .collection(DatabaseConstants.sessions)
      .doc(context.params.sessionId)
      .collection(DatabaseConstants.session_members)
      .get();

    sessionMembers.forEach(async (doc) => await doc.ref.delete());
  });

exports.joinCertifiedSession = functions.https.onCall(async (req, res) => {
  if (!res.auth) return;

  const userId = res.auth.uid;
  const sessionId = req.session_id;

  const sessionRef = firestore
    .collection(DatabaseConstants.sessions)
    .doc(sessionId);

  // add user as member in session
  await sessionRef
    .collection(DatabaseConstants.session_members)
    .doc(userId)
    .set({
      donation_amount: 0,
      id: userId,
    } as SessionMemberType);

  const session = (await sessionRef.get()).data() as SessionType;

  // add session to User
  await firestore
    .collection(DatabaseConstants.user)
    .doc(userId)
    .collection(DatabaseConstants.sessions)
    .doc(sessionId)
    .set({
      id: sessionId,
      session_name: session.session_name,
      session_description: session.session_description,
      amount_per_user: session.amount_per_user,
      created_at: session.created_at,
      end_date: session.end_date,
      creator_id: session.creator_id,
      campaign_id: session.campaign_id,
      img_url: session.img_url,
    } as UserSessionType);
});

exports.leaveCertifiedSession = functions.https.onCall(async (req, res) => {
  if (!res.auth) return;

  const userId = res.auth.uid;
  const sessionId = req.session_id;

  const sessionRef = firestore
    .collection(DatabaseConstants.sessions)
    .doc(sessionId);

  // remove user as member in session
  await sessionRef
    .collection(DatabaseConstants.session_members)
    .doc(userId)
    .delete();

  // add session to User
  await firestore
    .collection(DatabaseConstants.user)
    .doc(userId)
    .collection(DatabaseConstants.sessions)
    .doc(sessionId)
    .delete();
});
