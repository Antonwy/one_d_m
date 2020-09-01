import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { DatabaseConstants, DonationFields } from './database-constants';
import { StatisticType } from './types';
import { _namespaceWithOptions } from 'firebase-functions/lib/providers/firestore';

const firestore = admin.firestore();

exports.daily = functions.pubsub
  .schedule('0 0 * * *')
  .onRun(async (context) => {
    await resetStatistics({ daily_amount: 0 });
  });

exports.monthly = functions.pubsub
  .schedule('0 0 1 * *')
  .onRun(async (context) => {
    await resetStatistics({ monthly_amount: 0 });
  });

exports.yearly = functions.pubsub
  .schedule('0 0 * 1 *')
  .onRun(async (context) => {
    await resetStatistics({ yearly_amount: 0 });

    await chargeCustomers();
  });

async function resetStatistics(obj: StatisticType) {
  await firestore
    .collection(DatabaseConstants.statistics)
    .doc(DatabaseConstants.donation_info)
    .update(obj);
}

async function chargeCustomers() {
  const timeStamp = FirebaseFirestore.Timestamp;
  const now: Date = new Date();
  const previousMonth: Date = new Date();
  const month = now.getMonth();
  previousMonth.setMonth(now.getMonth() - 1);
  while (previousMonth.getMonth() === month) {
    previousMonth.setDate(previousMonth.getDate() - 1);
  }

  const donationsFromLastMonth = await firestore
    .collection(DatabaseConstants.donations)
    .where(DonationFields.created_at, '<', timeStamp.fromDate(now))
    .where(DonationFields.created_at, '>', timeStamp.fromDate(previousMonth))
    .get();

  
}
