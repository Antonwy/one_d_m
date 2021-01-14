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
      created_at: admin.firestore.Timestamp.now(),
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
    const bucket = admin.storage().bucket();

    await firestore
      .collection(DatabaseConstants.sessions)
      .doc(context.params.sessionId)
      .listCollections()
      .then(async (collectionList) => {
        collectionList.forEach(async (collection) => {
          await collection.get().then(async (collectionDocs) => {
            functions.logger.info(
              collection.id + ':' + collectionDocs.docs.length
            );
            collectionDocs.docs.forEach(async (doc) => {
              await doc.ref.delete();
            });
          });
        });
      })
      .catch((e) => {
        functions.logger.info(e);
      });
    await firestore
      .collection(DatabaseConstants.news)
      .where(DatabaseConstants.session_id, '==', context.params.sessionId)
      .get()
      .then(async (newsSnapshot) => {
        newsSnapshot.docs.forEach(async (doc) => {
          await doc.ref.delete().then(async () => {
            await bucket
              .deleteFiles({ prefix: `news/news_${doc.id}/` })
              .then(() => {
                functions.logger.info('news Files deleted successfully');
              })
              .catch((e) => {
                functions.logger.info(e);
              });
          });
        });
      })
      .catch(async (err) => {
        functions.logger.info(err);
      });

    // deleting images of of the news
    await bucket
      .deleteFiles({
        prefix: `certified_sessions/certified_session_${context.params.sessionId}/`,
      })
      .then(() => {
        functions.logger.info('Session Files deleted successfully');
      })
      .catch((e) => {
        functions.logger.info(e);
      });
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

  // increment member count
  await sessionRef.set(
    { member_count: admin.firestore.FieldValue.increment(1) },
    { merge: true }
  );

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

  // decrement member count
  await sessionRef.set(
    { member_count: admin.firestore.FieldValue.increment(-1) },
    { merge: true }
  );

  // add session to User
  await firestore
    .collection(DatabaseConstants.user)
    .doc(userId)
    .collection(DatabaseConstants.sessions)
    .doc(sessionId)
    .delete();
});

exports.onUpdateSession = functions.firestore
  .document(DatabaseConstants.sessions + '/{sessionId}')
  .onUpdate(async (snapshot, context) => {
    const sessionId = context.params.sessionId;
    const afterData = snapshot.after.data();
    snapshot.after.ref
      .collection(DatabaseConstants.session_members)
      .get()
      .then(async (sessionMembers) => {
        sessionMembers.docs.forEach(async (doc) => {
          await firestore
            .collection(DatabaseConstants.user)
            .doc(doc.id)
            .collection(DatabaseConstants.sessions)
            .doc(sessionId)
            .update(afterData)
            .then(() => {
              console.log("user's session updated");
            })
            .catch((error) => functions.logger.error(error));
        });
      })
      .catch((error) => {
        functions.logger.error(error);
      });
  });
