import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { DatabaseConstants, PrivateUserFields } from './database-constants';

const firestore = admin.firestore();

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

  // clean following/followed collections
  const followingCollectionRef = firestore.collection(
    DatabaseConstants.following
  );

  const followingCollection = await followingCollectionRef.get();

  // console.log(`followingCollection:\n${followingCollection}`);
  followingCollection.forEach(async (doc) => {
    const userDoc = await userRef.doc(doc.id).get();

    if (!userDoc.exists) {
      (await doc.ref.collection(DatabaseConstants.users).get()).forEach(
        async (d) => await d.ref.delete()
      );
      await doc.ref.delete();
    }
  });

  res.end();
});
