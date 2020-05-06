import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

exports.daily = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    await admin
      .firestore()
      .collection('statistics')
      .doc('donation_info')
      .update({
        daily_amount: 0,
      });
  });

// exports.monthly = functions.pubsub
//   .schedule('every month')
//   .onRun(async (context) => {
//     await admin
//       .firestore()
//       .collection('statistics')
//       .doc('donation_info')
//       .update({
//         daily_amount: 0,
//       });
//   });

// exports.yearly = functions.pubsub
//   .schedule('every year')
//   .onRun(async (context) => {
//     await admin
//       .firestore()
//       .collection('statistics')
//       .doc('donation_info')
//       .update({
//         daily_amount: 0,
//       });
//   });
