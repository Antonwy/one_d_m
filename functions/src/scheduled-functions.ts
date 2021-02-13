import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import {
  DatabaseConstants,
  ChargesFields,
  SessionFields,
} from './database-constants';
import { StatisticType, PrivateUserDataType } from './types';
import { _namespaceWithOptions } from 'firebase-functions/lib/providers/firestore';
import Stripe from 'stripe';

const stripe = new Stripe(functions.config().stripe.token, {
  apiVersion: '2020-03-02',
});

const firestore = admin.firestore();

exports.daily = functions.pubsub
  .schedule('0 0 * * *')
  .onRun(async (context) => {
    await resetStatistics({ daily_amount: 0 });
    await deleteOutdatedSessions();
  });

exports.dailyPoints = functions.pubsub
  .schedule('0 8 * * *')
  .timeZone('Europe/Berlin')
  .onRun(async (context) => {
    await sendDailyPoints();
  });

async function sendDailyPoints() {
  await firestore
    .collection(DatabaseConstants.user)
    .get()
    .then(async (userList) => {
      functions.logger.info('users length:' + userList.docs.length);
      userList.docs.forEach(async (user) => {
        // increment dv points
        const userDoc = firestore
          .collection(DatabaseConstants.user)
          .doc(user.id);

        await userDoc
          .collection(DatabaseConstants.advertising_data)
          .doc(DatabaseConstants.ad_balance)
          .set(
            {
              gift: 1,
            },
            { merge: true }
          );
        // send push notification
        const privData: PrivateUserDataType = (
          await userDoc
            .collection(DatabaseConstants.private_data)
            .doc(DatabaseConstants.data)
            .get()
        ).data() as PrivateUserDataType;

        console.log('Sending Pushmessages for daily points');

        if (
          privData?.device_token !== null &&
          privData?.device_token !== undefined &&
          privData?.device_token.length != 0
        ) {
          const payload = {
            notification: {
              title: 'Neuer Donation Vote!',
              body: `Öffne jetzt die App, um dir deinen DV einzusammeln!`,
            },
          };

          const pushRes = await admin
            .messaging()
            .sendToDevice(privData.device_token, payload)
            .catch((err) => functions.logger.info(err));
          console.log(pushRes);
        }
      });
    });
}

async function deleteOutdatedSessions() {
  const nowDate = admin.firestore.Timestamp.now();
  const outdatedSessions = await firestore
    .collection(DatabaseConstants.sessions)
    .where(SessionFields.end_date, '<', nowDate)
    .get();

  outdatedSessions.forEach(async (session) => await session.ref.delete());
}

exports.monthly = functions.pubsub
  .schedule('0 0 1 * *')
  .onRun(async (context) => {
    await resetStatistics({ monthly_amount: 0 });
    // await chargeCustomers();
  });

exports.yearly = functions.pubsub
  .schedule('0 0 * 1 *')
  .onRun(async (context) => {
    await resetStatistics({ yearly_amount: 0 });
  });

async function resetStatistics(obj: StatisticType) {
  await firestore
    .collection(DatabaseConstants.statistics)
    .doc(DatabaseConstants.donation_info)
    .update(obj);
}

exports.chargeCustomers = functions.https.onRequest(async (req, res) => {
  await chargeCustomers();
  res.end();
});

async function chargeCustomers() {
  console.log('Charging Customers');
  const chargedUsers = await firestore
    .collection(DatabaseConstants.charges_users)
    .where(ChargesFields.amount, '>', 4)
    .get();

  chargedUsers.forEach(async (chargeDoc) => {
    const amount: number = chargeDoc.data().amount;

    if (amount > 0) {
      const privateUserData: PrivateUserDataType = (
        await firestore
          .collection(DatabaseConstants.user)
          .doc(chargeDoc.id)
          .collection(DatabaseConstants.private_data)
          .doc(DatabaseConstants.data)
          .get()
      ).data() as PrivateUserDataType;

      const paymentMethod = (
        await firestore
          .collection(DatabaseConstants.user)
          .doc(chargeDoc.id)
          .collection(DatabaseConstants.cards)
          .get()
      ).docs[0];

      try {
        const payIntent: Stripe.PaymentIntent = await stripe.paymentIntents.create(
          {
            amount: amount * 10,
            currency: 'eur',
            customer: privateUserData.customer_id,
            receipt_email: privateUserData.email_address,
            description: chargeDoc.id,
            payment_method: paymentMethod.id,
            off_session: true,
            confirm: true,
          }
        );

        if (payIntent.status !== 'succeeded') {
          await firestore
            .collection(DatabaseConstants.charges_users)
            .doc(chargeDoc.id)
            .set(
              { error: true, error_desc: 'Something went wrong.' },
              { merge: true }
            );
        } else {
          await firestore
            .collection(DatabaseConstants.charges_users)
            .doc(chargeDoc.id)
            .set({ amount: 0, error: false }, { merge: true });
        }
      } catch (error) {
        await firestore
          .collection(DatabaseConstants.charges_users)
          .doc(chargeDoc.id)
          .set({ error: true }, { merge: true });
      }
    }
  });

  // await firestore.collection('mail').add({
  //   to: 'anton.wyrowski@gmail.com',
  //   message: {
  //     subject: 'Hello from Firebase!',
  //     text: 'This is the plaintext section of the email body.',
  //     html: 'This is the <code>HTML</code> section of the email body.',
  //   },
  // });
}
