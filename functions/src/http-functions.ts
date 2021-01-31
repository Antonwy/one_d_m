import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import {
  ChargesFields,
  DatabaseConstants,
  DonationFields,
  ImagePrefix,
  PrivateUserFields,
} from './database-constants';

const firestore = admin.firestore();

exports.deleteMe = functions.https.onRequest(async (req, res) => {
  let uid = 'dY8g6VBLAIPgNCjsC0Bv0fbnJjy1';

  // deletion of subscribed_campaigns and subcollections including documents
  await firestore
    .collection(DatabaseConstants.subscribed_campaigns)
    .doc(uid)
    .collection(DatabaseConstants.campaigns)
    .get()
    .then(async (campaignsList) => {
      functions.logger.info('Campaigns length:' + campaignsList.docs.length);
      campaignsList.docs.forEach(async (campaign) => {
        await firestore
          .collection(DatabaseConstants.campaigns_subscribed_users)
          .doc(campaign.id)
          .collection(DatabaseConstants.users)
          .doc(uid)
          .delete();
        await campaign.ref.delete().then(() => {
          functions.logger.info('campaign:' + campaign.id + ' deleted');
        });
      });
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
      functions.logger.info(
        'campaigns_subscribed_users length:' + sessionsList.docs.length
      );
      sessionsList.docs.forEach(async (session) => {
        await firestore
          .collection(DatabaseConstants.sessions)
          .doc(session.id)
          .collection(DatabaseConstants.session_members)
          .doc(uid)
          .delete();

        await firestore
          .collection(DatabaseConstants.sessions)
          .doc(session.id)
          .update({ member_count: admin.firestore.FieldValue.increment(-1) })
          .catch((err) =>
            functions.logger.error('Decrementing Session failed! ' + err)
          );
      });
    });

  // delete user from following
  await firestore
    .collection(DatabaseConstants.following)
    .doc(uid)
    .collection(DatabaseConstants.users)
    .get()
    .then(async (usersList) => {
      functions.logger.info('following length:' + usersList.docs.length);
      usersList.docs.forEach(async (doc) => await doc.ref.delete());
    });

  await firestore
    .collection(DatabaseConstants.donations)
    .where(DonationFields.user_id, '==', uid)
    .get()
    .then(async (donationsList) => {
      functions.logger.info('domations length:' + donationsList.docs.length);
      donationsList.docs.forEach(async (doc) => await doc.ref.delete());
    });

  await firestore
    .collection(DatabaseConstants.charges_users)
    .where(ChargesFields.user_id, '==', uid)
    .get()
    .then(async (chargesList) => {
      functions.logger.info('chargesList length:' + chargesList.docs.length);

      chargesList.docs.forEach(async (doc) => await doc.ref.delete());
    });

  await firestore
    .collection(DatabaseConstants.friends)
    .doc(uid)
    .collection('users')
    .get()
    .then(async (friendsList) => {
      functions.logger.info('friendslist length:' + friendsList.docs.length);
      friendsList.docs.forEach(async (doc) => await doc.ref.delete());
    });

  const userRef = await firestore.collection(DatabaseConstants.user).doc(uid);

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
      prefix: `${DatabaseConstants.users}/${ImagePrefix.user}_${uid}/`,
    })
    .then(() => {
      functions.logger.info('File deleted successfully');
    })
    .catch((e) => {
      functions.logger.info(e);
    });
});

exports.findFriends = functions.https.onCall(async (req, res) => {
  console.log(`Finding friends...`);
  if (res.auth?.uid === undefined) return;

  const authId: string = res.auth.uid;
  const numbers = req as string[];

  const userPrivateCollection = firestore.collectionGroup(
    DatabaseConstants.private_data
  );

  const userIdList: string[] = [];

  const tempContactNumbers: string[] = [...numbers];

  for (const contNumber of tempContactNumbers.filter(
    (num) => num.startsWith('+49') || num.startsWith('0')
  )) {
    contNumber.replace(/ /g, '');
    if (contNumber.startsWith('+49')) {
      numbers.push(contNumber.replace('+49', '0'));
    } else if (contNumber.startsWith('0')) {
      numbers.push(contNumber.replace('0', '+49'));
    }
  }

  console.log(`NumbersCount: ${numbers.length}`);

  let iterCounter: number = 0;

  for (let i = 0; i < numbers.length; i += 10) {
    const queryNumbers: string[] = numbers.slice(
      i,
      i + 10 > numbers.length ? numbers.length : i + 10
    );

    iterCounter = iterCounter + 1;

    const qs = await userPrivateCollection
      .where(PrivateUserFields.phone_number, 'in', queryNumbers)
      .get();

    if (qs.docs.length !== null) {
      for (const document of qs.docs) {
        const probUserId = document.ref.parent.parent?.id;
        if (probUserId !== undefined) userIdList.push(probUserId);
      }
    }
  }

  console.log(`Found ${userIdList.length} Friends`);

  userIdList.forEach(async (id) => {
    if (id === authId) return;
    await firestore
      .collection(DatabaseConstants.friends)
      .doc(authId)
      .collection(DatabaseConstants.users)
      .doc(id)
      .set({ id });
  });
});

exports.cleanDatabase = functions.https.onRequest(async (req, res) => {
  console.log('Starting cleaning...');
  const userRef = firestore.collection(DatabaseConstants.user);

  // clean subscribed Campaigns
  const subCampUserCollectionsRef = firestore.collection(
    DatabaseConstants.subscribed_campaigns
  );

  const subCampUserCollections = await subCampUserCollectionsRef.get();

  subCampUserCollections.forEach(async (doc) => {
    const userDoc = await userRef.doc(doc.id).get();

    if (!userDoc.exists) {
      (await doc.ref.collection(DatabaseConstants.campaigns).get()).forEach(
        async (d) => await d.ref.delete()
      );
      await doc.ref.delete();
    }
  });

  const usersRef = firestore.collection(DatabaseConstants.user);
  const usersCollection = await usersRef.get();

  usersCollection.forEach(async (doc) => {
    const followingUsers = await firestore
      .collection(DatabaseConstants.following)
      .doc(doc.id)
      .collection(DatabaseConstants.users)
      .get();
    followingUsers.forEach(async (u) => {
      const checkUser = await userRef.doc(u.id).get();
      if (!checkUser.exists) await u.ref.delete();
    });
  });

  res.end();
});
