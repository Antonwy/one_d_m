import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import {
  DatabaseConstants,
  DonationFields,
  PrivateUserFields,
} from './database-constants';
import { deleteUser } from './user-functions';
import { encode } from 'blurhash';
import { createCanvas, loadImage, Image } from 'canvas';
import { FeedType } from './types';

const firestore = admin.firestore();

exports.deleteUser = functions.https.onRequest(async (req, res) => {
  const uid = req.body.uid;

  functions.logger.info(`Deleting ${uid}`);

  await deleteUser(uid);

  res.end();
});

exports.cleanFollowing = functions.https.onRequest(async (req, res) => {
  functions.logger.info(`Cleaning following...`);

  await firestore
    .collection(DatabaseConstants.user)
    .get()
    .then(async (allUsers) => {
      allUsers.forEach((userDoc) => {
        firestore
          .collection(DatabaseConstants.following)
          .doc(userDoc.id)
          .collection(DatabaseConstants.users)
          .get()
          .then((followingUsers) => {
            const allUserIds = allUsers.docs.map((u) => u.id);

            followingUsers.forEach(async (fUser) => {
              if (!allUserIds.includes(fUser.id))
                await fUser.ref
                  .delete()
                  .catch((err) => functions.logger.info(err));
            });
          })
          .catch((err) => functions.logger.info(err));
      });
    })
    .catch((err) => functions.logger.info(err));

  res.end();
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

  for await (const id of userIdList) {
    if (id === authId) return;
    await firestore
      .collection(DatabaseConstants.friends)
      .doc(authId)
      .collection(DatabaseConstants.users)
      .doc(id)
      .set({ id });
  }
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

async function createBlurHashLocal(
  imgUrl: string
): Promise<String | undefined> {
  if (imgUrl === null || imgUrl === undefined) return undefined;

  const image = await loadImage(imgUrl);
  const imageData = getImageData(image);
  if (imageData?.data === undefined) return undefined;

  return encode(imageData.data, imageData?.width, imageData?.height, 4, 3);
}

export const createBlurHash = createBlurHashLocal;

const createBlurHashes = async (
  query: FirebaseFirestore.CollectionReference,
  imgParam = 'image_url'
) => {
  console.log(`Getting ${query.id}`);

  const queryData = await query.get();
  console.log(
    `Got ${query.id} it contains ${queryData.docs.length} documents.`
  );

  console.log('Starting to create hashes');

  for await (const doc of queryData.docs) {
    const docData = doc.data();
    const blurHash: string | undefined = docData.blur_hash;
    const imgUrl = docData[imgParam];

    if (
      imgUrl === null ||
      imgUrl === undefined ||
      (blurHash !== undefined && blurHash.length > 0)
    )
      continue;

    console.log(`Processing image with the url: ${imgUrl}`);

    const hash = await createBlurHashLocal(imgUrl);

    console.log(`Setting hash ${hash} for ${query.id} with id: ${doc.id}`);

    await query.doc(doc.id).set({ blur_hash: hash }, { merge: true });
  }

  return;
};

exports.createBlurHashesCampaigns = functions.https.onRequest(
  async (req, res) => {
    return createBlurHashes(firestore.collection(DatabaseConstants.campaigns));
  }
);

exports.createBlurHashesSessions = functions.https.onRequest(
  async (req, res) => {
    return createBlurHashes(
      firestore.collection(DatabaseConstants.sessions),
      'img_url'
    );
  }
);

exports.createBlurHashesUsers = functions.https.onRequest(async (req, res) => {
  return createBlurHashes(
    firestore.collection(DatabaseConstants.user),
    'thumbnail_url'
  );
});

const getImageData = (image: Image) => {
  const canvas = createCanvas(image.width, image.height);
  const context = canvas.getContext('2d');
  context.drawImage(image, 0, 0);
  return context.getImageData(0, 0, image.width, image.height);
};

exports.updateSessionDonationAmounts = functions.https.onRequest(
  async (req, res) => {
    console.log('Starting to update the amount of all session members');

    const sessions = await firestore
      .collection(DatabaseConstants.sessions)
      .get();

    console.log(`Got ${sessions.docs.length} Sessions`);

    for await (const session of sessions.docs) {
      const members = await session.ref
        .collection(DatabaseConstants.session_members)
        .get();

      console.log(
        `${session.data().session_name} has ${members.docs.length} members`
      );

      let sessionAmount = 0;

      for await (const member of members.docs) {
        const donationsFromSession = await firestore
          .collection(DatabaseConstants.donations)
          .where(DonationFields.user_id, '==', member.id)
          .where(DonationFields.session_id, '==', session.id)
          .get();

        console.log(
          `${member.id} made ${donationsFromSession.docs.length} donations to ${
            session.data().session_name
          }`
        );

        let userSessionAmount = 0;

        donationsFromSession.forEach(
          (doc) => (userSessionAmount += doc.data().amount)
        );

        console.log(
          `Summing up ${member.id} donated ${userSessionAmount} DVs to ${
            session.data().session_name
          }`
        );

        await member.ref.set({
          donation_amount: userSessionAmount,
          id: member.id,
        });

        sessionAmount += userSessionAmount;
      }

      console.log(
        `${session.data().session_name} collected ${sessionAmount} DVs`
      );

      await session.ref.set({ current_amount: sessionAmount }, { merge: true });
    }
  }
);

exports.createNotificationFeed = functions.https.onRequest(async (req, res) => {
  console.log('Starting to create the notification feed for all users');
  const users = await firestore.collection(DatabaseConstants.user).get();

  console.log(`Found ${users.docs.length} users!`);

  for await (const user of users.docs) {
    console.log(`Starting to create ${user.data().name}'s feed!`);

    const followers = await firestore
      .collection(DatabaseConstants.followed)
      .doc(user.id)
      .collection(DatabaseConstants.users)
      .get();

    console.log(`${user.data().name} has ${followers.docs.length} follwer!`);

    for await (const follower of followers.docs) {
      let createdAt = admin.firestore.Timestamp.now();
      if (
        follower.data().createdAt !== null &&
        follower.data().createdAt !== undefined
      )
        createdAt = follower.data().createdAt;

      console.log(`Copying ${follower.id} to ${user.data().name}'s feed!`);

      await firestore
        .collection(DatabaseConstants.feed)
        .doc(user.id)
        .collection(DatabaseConstants.feed_data)
        .doc(follower.id)
        .set({
          feed_type: 'follow',
          created_at: createdAt,
          id: follower.id,
        } as FeedType);
    }

    await firestore
      .collection(DatabaseConstants.feed)
      .doc(user.id)
      .set({ unseen_objects: [] });

    console.log(`Finished ${user.data().name}'s feed!`);
  }
});

exports.deleteOutdatedSurveys = functions.https.onRequest(async (req, res) => {
  const feed = await firestore.collection(DatabaseConstants.feed).get();
  const notExistingSurveys: [string] = ['test'];

  console.log(`Found ${feed.docs.length}  documents!`);

  for await (const feedUser of feed.docs) {
    console.log(`Start checking ${feedUser.id}'s Feed`);
    const surveys = await feedUser.ref
      .collection(DatabaseConstants.feed_data)
      .where('feed_type', '==', 'survey')
      .get();

    for await (const feedSurvey of surveys.docs) {
      if (notExistingSurveys.includes(feedSurvey.id)) {
        console.log(`Deleting ${feedSurvey.id} from ${feedUser.id}'s Feed`);
        await feedSurvey.ref.delete();
        continue;
      }

      const rSurvey = await firestore
        .collection(DatabaseConstants.surveys)
        .doc(feedSurvey.id)
        .get();

      if (!rSurvey.exists) {
        console.log(`Deleting ${feedSurvey.id} from ${feedUser.id}'s Feed`);
        notExistingSurveys.push(feedSurvey.id);
        await feedSurvey.ref.delete();
      }
    }
  }

  console.log(`Not Existing Surveys: ${notExistingSurveys}`);
});
