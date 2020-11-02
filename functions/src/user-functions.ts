import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { UserType, PrivateUserDataType } from './types';
import Stripe from 'stripe';
import {
  DatabaseConstants,
  ImagePrefix,
  DonationFields,
  CampaignFields,
} from './database-constants';

const stripe = new Stripe(functions.config().stripe.token, {
  apiVersion: '2020-03-02',
});

const firestore = admin.firestore();
const increment = admin.firestore.FieldValue.increment;

exports.onCreateUser = functions.firestore
  .document(`${DatabaseConstants.user}/{userId}`)
  .onCreate(async (snapshot, context) => {
    const userId: string = context.params.userId;
    const user = await admin.auth().getUser(userId);

    const customer: Stripe.Customer = await stripe.customers.create({});

    await firestore
      .collection(DatabaseConstants.user)
      .doc(user.uid)
      .collection(DatabaseConstants.private_data)
      .doc(DatabaseConstants.data)
      .set(
        {
          email_address: user.email,
          phone_number: '',
          customer_id: customer.id,
        } as PrivateUserDataType,
        { merge: true }
      );

    return firestore
      .collection(DatabaseConstants.statistics)
      .doc(DatabaseConstants.users_info)
      .update({ user_count: increment(1) });
  });

exports.onDeleteAuthUser = functions.auth.user().onDelete(async (user) => {
  const isOrganisation: boolean = (
    await firestore
      .collection(DatabaseConstants.organisations)
      .doc(user.uid)
      .get()
  ).exists;

  if (isOrganisation) {
    await firestore
      .collection(DatabaseConstants.organisations)
      .doc(user.uid)
      .delete();

    const campaignsToDelete = await firestore
      .collection(DatabaseConstants.campaigns)
      .where(CampaignFields.author_id, '==', user.uid)
      .get();

    campaignsToDelete.forEach(async (campaign) => await campaign.ref.delete());
    return;
  }

  return firestore.collection(DatabaseConstants.user).doc(user.uid).delete();
});

exports.onUpdateUser = functions.firestore
  .document(`${DatabaseConstants.user}/{userId}`)
  .onUpdate(async (snapshot, context) => {
    const userId: string = context.params.userId;
    const beforeUser: UserType = snapshot.before.data() as UserType;
    const afterUser: UserType = snapshot.after.data() as UserType;

    if (beforeUser.image_url !== null && afterUser.image_url === null) {
      await admin
        .storage()
        .bucket()
        .deleteFiles({
          prefix: `${DatabaseConstants.users}/${ImagePrefix.user}_${userId}/`,
        });
    }
  });

exports.onDeleteUser = functions.firestore
  .document(`${DatabaseConstants.user}/{userId}`)
  .onDelete(async (snapshot, context) => {
    const userId: string = context.params.userId;
    const user: UserType = snapshot.data() as UserType;

    const userRef = firestore.collection(DatabaseConstants.user).doc(userId);
    const privateRef = userRef
      .collection(DatabaseConstants.private_data)
      .doc(DatabaseConstants.data);
    const cardRef = userRef.collection(DatabaseConstants.cards);
    const adRef = userRef.collection(DatabaseConstants.advertising_data);
    const sessionsRef = userRef.collection(DatabaseConstants.sessions);
    const sessionsInvitesRef = userRef.collection(
      DatabaseConstants.session_invites
    );

    const privateUserData: PrivateUserDataType = (
      await privateRef.get()
    ).data() as PrivateUserDataType;

    // delete Cards
    (await cardRef.get()).forEach(async (c) => await c.ref.delete());

    //delete ads
    (await adRef.get()).forEach(async (doc) => await doc.ref.delete());

    // delete sessions
    (await sessionsRef.get()).forEach(async (doc) => await doc.ref.delete());

    // delete sessions invites
    (await sessionsInvitesRef.get()).forEach(
      async (doc) => await doc.ref.delete()
    );

    // delete privateData
    await privateRef.delete();

    if (!(await userRef.get()).exists) return;

    (
      await firestore
        .collection(DatabaseConstants.friends)
        .doc(userId)
        .collection(DatabaseConstants.users)
        .get()
    ).forEach(async (doc) => await doc.ref.delete());

    if (privateUserData.customer_id !== undefined)
      await stripe.customers.del(privateUserData.customer_id);

    // delete following
    const followingUserColl = await firestore
      .collection(DatabaseConstants.following)
      .doc(userId)
      .collection(DatabaseConstants.users)
      .get();

    // delete follow and FriendRanking
    followingUserColl.forEach(async (doc) => await doc.ref.delete());

    // delete donations
    const qs = await firestore
      .collection(DatabaseConstants.donations)
      .where(DonationFields.user_id, '==', userId)
      .get();
    qs.forEach(async (doc) => await doc.ref.delete());

    // decrement campaign subscribe count
    user.subscribed_campaigns.forEach(
      async (id) =>
        await firestore
          .collection(DatabaseConstants.campaigns)
          .doc(id)
          .update({
            subscribed_count: increment(-1),
          })
    );

    // decrement user count
    await firestore
      .collection(DatabaseConstants.statistics)
      .doc(DatabaseConstants.users_info)
      .update({ user_count: increment(-1) });

    // delete subscribed_campaigns
    (
      await firestore
        .collection(DatabaseConstants.subscribed_campaigns)
        .doc(userId)
        .collection(DatabaseConstants.campaigns)
        .get()
    ).forEach(async (doc) => await doc.ref.delete());

    if (user.image_url === null || !user.image_url.startsWith('user_')) return;

    await admin
      .storage()
      .bucket()
      .deleteFiles({
        prefix: `${DatabaseConstants.users}/${ImagePrefix.user}_${userId}/`,
      });
  });

exports.onAddCard = functions.firestore
  .document(
    `${DatabaseConstants.user}/{userId}/${DatabaseConstants.cards}/{token}`
  )
  .onCreate(async (snapshot, context) => {
    const token: string = context.params.token;
    const userId: string = context.params.userId;

    const privateUserData: PrivateUserDataType = (
      await firestore
        .collection(DatabaseConstants.user)
        .doc(userId)
        .collection(DatabaseConstants.private_data)
        .doc(DatabaseConstants.data)
        .get()
    ).data() as PrivateUserDataType;

    await stripe.paymentMethods.attach(token, {
      customer: privateUserData.customer_id,
    });
  });

exports.onDeleteCard = functions.firestore
  .document(
    `${DatabaseConstants.user}/{userId}/${DatabaseConstants.cards}/{token}`
  )
  .onDelete(async (snapshot, context) => {
    const token: string = context.params.token;

    return await stripe.paymentMethods.detach(token);
  });
