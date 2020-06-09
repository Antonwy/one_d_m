import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const firestore = admin.firestore();

// exports.updateDb = functions.https.onCall(async (req, res) => {
//   console.log('Updating the DB...');

//   const donations = (await firestore.collection('donations').get()).docs;

//   console.log(donations);

//   donations.forEach(async (value) => {
//     const donation: Donation = value.data() as Donation;

//     const authorId = donation.user_id;

//     const followedUsers = (
//       await firestore
//         .collection('followed')
//         .doc(authorId)
//         .collection('users')
//         .get()
//     ).docs;

//     console.log(followedUsers);

//     followedUsers.forEach(async (doc) => {
//       const id = doc.id;
//       await firestore
//         .collection('donation_feed')
//         .doc(id)
//         .collection('sorted_donations')
//         .doc(getDate(donation.created_at.toDate()))
//         .collection('users')
//         .doc(donation.user_id)
//         .collection('donations')
//         .doc(donation.campaign_id)
//         .set({
//           amount: admin.firestore.FieldValue.increment(donation.amount),
//           user_id: donation.user_id,
//           campaign_name: donation.campaign_name,
//           campaign_id: donation.campaign_id,
//           campaign_img_url: donation.campaign_img_url,
//         });
//     });
//   });
// });

// function getDate(nowDate: Date): string {
//   return `${nowDate.getFullYear()}-${
//     nowDate.getMonth() + 1
//   }-${nowDate.getDate()}`;
// }

// exports.updateDonations = functions.https.onCall(async (req, res) => {
//   console.log('Updating donations');

//   const donations = await firestore.collection('donations').get();

//   donations.forEach(
//     async (doc) =>
//       await doc.ref.set(
//         {
//           anonym: false,
//         },
//         { merge: true }
//       )
//   );
// });

exports.findFriends = functions.https.onCall(async (req, res) => {
  console.log(`Finding friends...`);
  if (res.auth?.uid === undefined) return;

  const authId: string = res.auth.uid;
  const numbers = req as string[];

  const userPrivateCollection = firestore.collectionGroup('private_data');

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

  var iterCounter: number = 0;

  for (let i = 0; i < numbers.length; i += 10) {
    const queryNumbers: string[] = numbers.slice(
      i,
      i + 10 > numbers.length ? numbers.length : i + 10
    );

    iterCounter = iterCounter + 1;

    const qs = await userPrivateCollection
      .where('phone_number', 'in', queryNumbers)
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
      .collection('friends')
      .doc(authId)
      .collection('users')
      .doc(id)
      .set({ id });
  });
});
