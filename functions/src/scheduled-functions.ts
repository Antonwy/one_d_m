import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

exports.daily = functions.pubsub
  .schedule('0 0 * * *')
  .onRun(async (context) => {
    await admin
      .firestore()
      .collection('statistics')
      .doc('donation_info')
      .update({
        daily_amount: 0,
      });
  });

exports.monthly = functions.pubsub
  .schedule('0 0 1 * *')
  .onRun(async (context) => {
    await admin
      .firestore()
      .collection('statistics')
      .doc('donation_info')
      .update({
        daily_amount: 0,
      });
  });

exports.yearly = functions.pubsub
  .schedule('0 0 * 1 *')
  .onRun(async (context) => {
    await admin
      .firestore()
      .collection('statistics')
      .doc('donation_info')
      .update({
        daily_amount: 0,
      });
  });
