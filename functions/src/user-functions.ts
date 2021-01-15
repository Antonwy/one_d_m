import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { UserType, PrivateUserDataType } from './types';
import Stripe from 'stripe';
import {
  ImagePrefix,
  DonationFields,
  DatabaseConstants,
  ChargesFields,
  ImageResolutions,
  ImageSuffix,
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
          customer_id: customer.id,
        } as PrivateUserDataType,
        { merge: true }
      );

    await firestore
      .collection(DatabaseConstants.user)
      .doc(user.uid)
      .collection(DatabaseConstants.advertising_data)
      .doc(DatabaseConstants.ad_balance)
      .set(
        {
          dc_balance: 3,
          activity_score: 0,
        },
        { merge: true }
      );

    return firestore
      .collection(DatabaseConstants.statistics)
      .doc(DatabaseConstants.users_info)
      .update({ user_count: increment(1) });
  });

exports.onDeleteAuthUser = functions.auth.user().onDelete(async (user) => {
  if (
    !(await firestore.collection(DatabaseConstants.user).doc(user.uid).get())
      .exists
  ) {
    await firestore
      .collection(DatabaseConstants.organisations)
      .doc(user.uid)
      .delete();

    return;
  }

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

        await firestore
          .collection(DatabaseConstants.sessions)
          .doc(session.id)
          .update({ member_count: admin.firestore.FieldValue.increment(-1) });
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

  await firestore
    .collection(DatabaseConstants.friends)
    .doc(user.uid)
    .collection('users')
    .get()
    .then(async (friendsList) => {
      functions.logger.info('friendslist length:' + friendsList.docs.length);
      friendsList.docs.forEach(async (doc) => await doc.ref.delete());
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

  const bucket = admin.storage().bucket();
  await bucket
    .deleteFiles({
      prefix: `${DatabaseConstants.users}/${ImagePrefix.user}_${user.uid}/`,
    })
    .then(() => {
      functions.logger.info('File deleted successfully');
    })
    .catch((e) => {
      functions.logger.info(e);
    });

  return 'OK';
});

exports.onUpdateUser = functions.firestore
  .document(`${DatabaseConstants.user}/{userId}`)
  .onUpdate(async (snapshot, context) => {
    const userId: string = context.params.userId;
    const beforeUser: UserType = snapshot.before.data() as UserType;
    const afterUser: UserType = snapshot.after.data() as UserType;

    if (
      beforeUser.image_url !== null &&
      afterUser.image_url === null &&
      beforeUser.image_url.endsWith(
        `${ImageResolutions.high}${ImageSuffix.dottJpg}`
      )
    ) {
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

    return admin
      .auth()
      .deleteUser(userId)
      .then(() => functions.logger.info('Deleted User'))
      .catch((e) => functions.logger.error(e));
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
