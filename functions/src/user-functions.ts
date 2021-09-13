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
import { addDv } from './api';

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

    await firestore.collection(DatabaseConstants.feed).doc(user.uid).set({
      unseen_objects: [],
    });

    return firestore
      .collection(DatabaseConstants.statistics)
      .doc(DatabaseConstants.users_info)
      .update({ user_count: increment(1) });
  });

exports.onDeleteAuthUser = functions.auth.user().onDelete(async (u) => {
  await deleteUser(u.uid);
});

exports.onUpdateUserBalance = functions.firestore
  .document(`${DatabaseConstants.user}/{userId}/ad_data/{docId}`)
  .onUpdate(async (snapshot, context) => {
    const oldValue = snapshot.before.data(),
      newValue = snapshot.after.data();

    const diffValue = newValue.dc_balance - oldValue.dc_balance;
    console.log(diffValue);

    if (diffValue > 0) {
      await addDv(diffValue, context.auth?.uid ?? context.params.userId);
    }
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
      .catch(async (e) => {
        functions.logger.error('Auth user not found: ' + e);
        functions.logger.error('Deleting now UserData!');
        await deleteUser(userId);
      });
  });

export async function deleteUser(uid: string) {
  let isOrganization: boolean = false;

  await firestore
    .collection(DatabaseConstants.organisations)
    .doc(uid)
    .get()
    .then((val) => (isOrganization = val.exists))
    .catch((err) => (isOrganization = false));

  if (isOrganization) {
    await firestore
      .collection(DatabaseConstants.organisations)
      .doc(uid)
      .delete()
      .then((val) =>
        functions.logger.info(`Deleted successfully organization ${uid}.`)
      )
      .catch((err) =>
        functions.logger.info(
          `Deleting organization ${uid} failed. Because of ${err}`
        )
      );

    return;
  }

  // deletion of subscribed_campaigns and subcollections including documents
  await firestore
    .collection(DatabaseConstants.subscribed_campaigns)
    .doc(uid)
    .collection(DatabaseConstants.campaigns)
    .get()
    .then(async (campaignsList) => {
      functions.logger.info('Campaigns length:' + campaignsList.docs.length);
      for await (const campaign of campaignsList.docs) {
        await firestore
          .collection(DatabaseConstants.campaigns_subscribed_users)
          .doc(campaign.id)
          .collection(DatabaseConstants.users)
          .doc(uid)
          .delete()
          .catch((err) =>
            functions.logger.info(
              `Something went wrong deleting user ${uid} from CampaignsSubscribedUsers ${campaign.id} because of ${err}`
            )
          );
        await campaign.ref.delete().then(() => {
          functions.logger.info('campaign:' + campaign.id + ' deleted');
        });
      }
    })
    .catch((e) => {
      functions.logger.error(e);
    });

  await firestore
    .collection(DatabaseConstants.subscribed_campaigns)
    .doc(uid)
    .delete()
    .then(() => {
      functions.logger.info('user deleted from subscribed_campaigns');
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
    .doc(uid)
    .collection(DatabaseConstants.sessions)
    .get()
    .then(async (sessionsList) => {
      functions.logger.info('sessions length:' + sessionsList.docs.length);
      for await (const session of sessionsList.docs) {
        await firestore
          .collection(DatabaseConstants.sessions)
          .doc(session.id)
          .collection(DatabaseConstants.session_members)
          .doc(uid)
          .delete()
          .catch((err) =>
            functions.logger.info(
              `Something went wrong deleting user ${uid} from Session ${session.id} because of ${err}`
            )
          );

        await firestore
          .collection(DatabaseConstants.sessions)
          .doc(session.id)
          .update({ member_count: admin.firestore.FieldValue.increment(-1) })
          .catch((err) =>
            functions.logger.error('Decrementing Session failed! ' + err)
          );
      }
    });

  // delete user from following
  await firestore
    .collection(DatabaseConstants.following)
    .doc(uid)
    .collection(DatabaseConstants.users)
    .get()
    .then(async (usersList) => {
      functions.logger.info('following length:' + usersList.docs.length);
      for await (const doc of usersList.docs) {
        await doc.ref.delete();
      }
    })
    .catch((err) => functions.logger.info(err));

  await firestore
    .collection(DatabaseConstants.donations)
    .where(DonationFields.user_id, '==', uid)
    .get()
    .then(async (donationsList) => {
      functions.logger.info('domations length:' + donationsList.docs.length);
      for await (const doc of donationsList.docs) {
        await doc.ref.delete();
      }
    })
    .catch((err) => functions.logger.info(err));

  await firestore
    .collection(DatabaseConstants.charges_users)
    .where(ChargesFields.user_id, '==', uid)
    .get()
    .then(async (chargesList) => {
      functions.logger.info('chargesList length:' + chargesList.docs.length);

      for await (const doc of chargesList.docs) {
        await doc.ref.delete();
      }
    })
    .catch((err) => functions.logger.info(err));

  await firestore
    .collection(DatabaseConstants.friends)
    .doc(uid)
    .collection('users')
    .get()
    .then(async (friendsList) => {
      functions.logger.info('friendslist length:' + friendsList.docs.length);
      for await (const doc of friendsList.docs) {
        await doc.ref.delete();
      }
    })
    .catch((err) => functions.logger.info(err));

  const userRef = firestore.collection(DatabaseConstants.user).doc(uid);

  userRef
    .listCollections()
    .then(async (collectionList) => {
      for await (const collection of collectionList) {
        await collection.get().then(async (docsList) => {
          for await (const doc of docsList.docs) {
            await doc.ref.delete();
          }
        });
      }
    })
    .catch((e) => {
      functions.logger.error(e);
    });

  await userRef.delete();

  const bucket = admin.storage().bucket();
  await bucket
    .deleteFiles({
      prefix: `${DatabaseConstants.users}/${ImagePrefix.user}_${uid}/`,
    })
    .then(() => {
      functions.logger.info('File deleted successfully');
    })
    .catch((e) => {
      functions.logger.info(e);
    });

  return 'OK';
}

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
