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
    await chargeCustomers();
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
