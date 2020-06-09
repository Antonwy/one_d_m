import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { User, PrivateUserData } from './types';
import Stripe from 'stripe';
const stripe = new Stripe(functions.config().stripe.token, {
  apiVersion: '2020-03-02',
});

const firestore = admin.firestore();

exports.onCreateAuthUser = functions.auth.user().onCreate(async (user) => {
  const customer: Stripe.Customer = await stripe.customers.create({});

  await firestore
    .collection('user')
    .doc(user.uid)
    .collection('private_data')
    .doc('data')
    .set(
      {
        email_address: user.email,
        phone_number: '',
        customer_id: customer.id,
      } as PrivateUserData,
      { merge: true }
    );

  return firestore
    .collection('statistics')
    .doc('users_info')
    .update({ user_count: admin.firestore.FieldValue.increment(1) });
});

exports.onDeleteAuthUser = functions.auth.user().onDelete(async (user) => {
  const userRef = firestore.collection('user').doc(user.uid);

  const privateUserData: PrivateUserData = (
    await userRef.collection('private_data').doc('data').get()
  ).data() as PrivateUserData;
  (await userRef.collection('cards').get()).forEach(
    async (c) => await c.ref.delete()
  );
  await userRef.collection('private_data').doc('data').delete();

  if (!(await userRef.get()).exists) return;

  (
    await firestore
      .collection('friends')
      .doc(user.uid)
      .collection('users')
      .get()
  ).forEach(async (doc) => await doc.ref.delete());

  if (privateUserData.customer_id !== undefined)
    await stripe.customers.del(privateUserData.customer_id);

  return userRef.delete();
});

exports.onUpdateUser = functions.firestore
  .document('user/{userId}')
  .onUpdate(async (snapshot, context) => {
    const userId: string = context.params.userId;
    const beforeUser: User = snapshot.before.data() as User;
    const afterUser: User = snapshot.after.data() as User;

    if (beforeUser.image_url !== null && afterUser.image_url === null) {
      await admin.storage().bucket().file(`user_${userId}.jpg`).delete();
      await admin
        .storage()
        .bucket()
        .file(`user_${userId}_300x300.jpg`)
        .delete();
      await admin
        .storage()
        .bucket()
        .file(`user_${userId}_1080x1920.jpg`)
        .delete();
    }
  });

exports.onDeleteUser = functions.firestore
  .document('user/{userId}')
  .onDelete(async (snapshot, context) => {
    const userId: string = context.params.userId;
    const user: User = snapshot.data() as User;

    // delete following
    const followingUserColl = await firestore
      .collection('following')
      .doc(userId)
      .collection('users')
      .get();

    // delete follow and FriendRanking
    followingUserColl.forEach(async (doc) => {
      const dailyDonationsRanking = await firestore
        .collection('donation_feed')
        .doc(doc.id)
        .collection('daily_rankings')
        .get();
      dailyDonationsRanking.forEach(async (dailyDoc) => {
        const foundDailyDoc = await firestore
          .collection('donation_feed')
          .doc(doc.id)
          .collection('daily_rankings')
          .doc(dailyDoc.id)
          .collection('users')
          .doc(userId)
          .get();

        if (dailyDoc.exists) await foundDailyDoc.ref.delete();
      });
      await doc.ref.delete();
    });

    // delete donations
    const qs = await firestore
      .collection('donations')
      .where('user_id', '==', userId)
      .get();
    qs.forEach(async (doc) => await doc.ref.delete());

    // decrement campaign subscribe count
    user.subscribed_campaigns.forEach(
      async (id) =>
        await firestore
          .collection('campaigns')
          .doc(id)
          .update({
            subscribed_count: admin.firestore.FieldValue.increment(-1),
          })
    );

    await firestore
      .collection('statistics')
      .doc('users_info')
      .update({ user_count: admin.firestore.FieldValue.increment(-1) });

    if (user.image_url === null || !user.image_url.startsWith('user_')) return;

    // delete image
    await admin
      .storage()
      .bucket()
      .file(`user_${userId}_1080x1920.jpg`)
      .delete();
    await admin.storage().bucket().file(`user_${userId}_300x300.jpg`).delete();
    await admin.storage().bucket().file(`user_${userId}.jpg`).delete();
  });

exports.onAddCard = functions.firestore
  .document('user/{userId}/cards/{token}')
  .onCreate(async (snapshot, context) => {
    const token: string = context.params.token;
    const userId: string = context.params.userId;

    const privateUserData: PrivateUserData = (
      await firestore
        .collection('user')
        .doc(userId)
        .collection('private_data')
        .doc('data')
        .get()
    ).data() as PrivateUserData;

    await stripe.paymentMethods.attach(token, {
      customer: privateUserData.customer_id,
    });
  });

exports.onDeleteCard = functions.firestore
  .document('user/{userId}/cards/{token}')
  .onDelete(async (snapshot, context) => {
    const token: string = context.params.token;

    return await stripe.paymentMethods.detach(token);
  });
