import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { UserType, PrivateUserDataType } from './types';
import Stripe from 'stripe';
import {
  ImagePrefix,
  DonationFields,
  DatabaseConstants,
  ChargesFields,
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
  // deletion of subscribed_campaigns and subcollections including documents
  await firestore
    .collection(DatabaseConstants.subscribed_campaigns)
    .doc(user.uid)
    .delete()
    .then(() => {
      functions.logger.info('user deleted from subscribed_campaigns');
    })
    .catch((e) => {
      functions.logger.error(e);
    });
  await firestore
    .collection(DatabaseConstants.subscribed_campaigns)
    .doc(user.uid)
    .collection(DatabaseConstants.campaigns)
    .get()
    .then(async (campaignsList) => {
      functions.logger.info('Campaigns length:' + campaignsList.docs.length);
      campaignsList.docs.forEach(async (campaign) => {
        await firestore
          .collection(DatabaseConstants.campaigns_subscribed_users)
          .doc(campaign.id)
          .collection(DatabaseConstants.users)
          .doc(user.uid)
          .delete();
        await campaign.ref.delete().then(() => {
          functions.logger.info('campaign:' + campaign.id + ' deleted');
        });
      });
    })
    .catch((e) => {
      functions.logger.error(e);
    });
  // user count decrease by one
  await firestore
    .collection(DatabaseConstants.statistics)
    .doc(DatabaseConstants.users_info)
    .update({ user_count: admin.firestore.FieldValue.increment(-1) })
    .then(() => {
      functions.logger.info('user count decrease');
    })
    .catch((e) => {
      functions.logger.error(e);
    });
  // delete subscribe sessions
  await firestore
    .collection(DatabaseConstants.user)
    .doc(user.uid)
    .collection(DatabaseConstants.sessions)
    .get()
    .then(async (sessionsList) => {
      functions.logger.info(
        'campaigns_subscribed_users length:' + sessionsList.docs.length
      );
      sessionsList.docs.forEach(async (session) => {
        await firestore
          .collection(DatabaseConstants.sessions)
          .doc(session.id)
          .collection(DatabaseConstants.session_members)
          .doc(user.uid)
          .delete();
      });
    });

  // delete user from following
  await firestore
    .collection(DatabaseConstants.following)
    .doc(user.uid)
    .collection(DatabaseConstants.users)
    .get()
    .then(async (usersList) => {
      functions.logger.info('following length:' + usersList.docs.length);
      usersList.docs.forEach(async (doc) => await doc.ref.delete());
    });
  // delete user from followed
  await firestore
    .collection(DatabaseConstants.followed)
    .doc(user.uid)
    .collection(DatabaseConstants.users)
    .get()
    .then(async (usersList) => {
      functions.logger.info('followed length:' + usersList.docs.length);
      usersList.docs.forEach(async (doc) => await doc.ref.delete());
    });

  await firestore
    .collection(DatabaseConstants.donations)
    .where(DonationFields.user_id, '==', user.uid)
    .get()
    .then(async (donationsList) => {
      functions.logger.info('domations length:' + donationsList.docs.length);
      donationsList.docs.forEach(async (doc) => await doc.ref.delete());
    });

  await firestore
    .collection(DatabaseConstants.charges_users)
    .where(ChargesFields.user_id, '==', user.uid)
    .get()
    .then(async (chargesList) => {
      functions.logger.info('chargesList length:' + chargesList.docs.length);

      chargesList.docs.forEach(async (doc) => await doc.ref.delete());
    });
  const userRef = await firestore
    .collection(DatabaseConstants.user)
    .doc(user.uid);
  userRef
    .listCollections()
    .then(async (collectionList) => {
      collectionList.forEach(async (collection) => {
        await collection.get().then(async (docsList) => {
          docsList.docs.forEach(async (doc) => await doc.ref.delete());
        });
      });
    })
    .catch((e) => {
      functions.logger.error(e);
    });
  await userRef.delete();
  return 'OK';
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
