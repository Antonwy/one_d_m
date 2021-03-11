import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { DonationType, ChargesType } from './types';
import { DatabaseConstants } from './database-constants';

const firestore = admin.firestore();
const increment = admin.firestore.FieldValue.increment;

exports.onCreateDonation = functions
  .region('europe-west3')
  .firestore.document(`${DatabaseConstants.donations}/{donationId}`)
  .onCreate(async (snapshot, context) => {
    if (snapshot.data() === undefined) return;

    const donation: DonationType = snapshot.data() as DonationType;

    // update the donation amount of the user that created the donation
    await firestore
      .collection(DatabaseConstants.user)
      .doc(donation.user_id)
      .update({
        donated_amount: increment(donation.amount),
      })
      .catch((err) =>
        functions.logger.info(
          `Updating donated_amount of user ${donation.user_id} failed! Error: ${err}`
        )
      );

    // update the amounts of donations from the campaign
    await firestore
      .collection(DatabaseConstants.campaigns)
      .doc(donation.campaign_id)
      .update({
        current_amount: increment(donation.amount),
      })
      .catch((err) =>
        functions.logger.info(
          `Updating current_amount of campaign ${donation.campaign_id} failed! Error: ${err}`
        )
      );

    // update the daily/monthly/yearly donations
    await firestore
      .collection(DatabaseConstants.statistics)
      .doc(DatabaseConstants.donation_info)
      .update({
        daily_amount: increment(donation.amount),
        monthly_amount: increment(donation.amount),
        yearly_amount: increment(donation.amount),
        donations_count: increment(1),
        all_donations: increment(donation.amount),
      })
      .catch((err) =>
        functions.logger.info(
          `Updating donated_amount of statistics failed! Error: ${err}`
        )
      );

    // update the donatedAmount in Session Members and session
    if (
      donation.session_id !== null &&
      donation.session_id !== undefined &&
      donation.session_id.length != 0
    ) {
      const isSessionMember = (
        await firestore
          .collection(DatabaseConstants.sessions)
          .doc(donation.session_id)
          .collection(DatabaseConstants.session_members)
          .doc(donation.user_id)
          .get()
      ).exists;

      if (isSessionMember) {
        await firestore
          .collection(DatabaseConstants.sessions)
          .doc(donation.session_id)
          .collection(DatabaseConstants.session_members)
          .doc(donation.user_id)
          .update({ donation_amount: increment(donation.amount) })
          .catch((err) =>
            functions.logger.info(
              `Updating donated_amount of session_member ${donation.user_id} failed! Error: ${err}`
            )
          );
      }

      const sessionRef = firestore
        .collection(DatabaseConstants.sessions)
        .doc(donation.session_id);
      await sessionRef
        .get()
        .then(async (sess) => {
          if (
            sess.data() !== undefined &&
            (sess.data()?.donation_goal ?? 0) > 0
          ) {
            await sess.ref.update({
              donation_goal_current: increment(
                Math.round(
                  donation.amount / (sess.data()?.donation_unit_value ?? 1)
                )
              ),
            });
          }
        })
        .catch((err) =>
          functions.logger.info(
            `Error getting session ${donation.session_id}! Error: ${err}`
          )
        );

      await sessionRef
        .update({ current_amount: increment(donation.amount) })
        .catch((err) =>
          functions.logger.info(
            `Updating current_amount of session ${donation.session_id} failed! Error: ${err}`
          )
        );
    }

    let availableDCs: number = 0;

    if (donation.useDCs) {
      const balanceRes = await firestore
        .collection(DatabaseConstants.user)
        .doc(donation.user_id)
        .collection(DatabaseConstants.advertising_data)
        .doc(DatabaseConstants.ad_balance)
        .get();
      const balanceData = balanceRes.data();

      if (balanceData !== undefined) availableDCs = balanceData.dc_balance;
    }

    const maxDCsToUse: number = Math.min(donation.amount, availableDCs);

    const campaignCharge: ChargesType = {
      amount: increment(donation.amount),
      campaign_id: donation.campaign_id,
    };

    await firestore
      .collection(DatabaseConstants.charges_campaigns)
      .doc(donation.campaign_id)
      .set(campaignCharge, { merge: true })
      .catch((err) =>
        functions.logger.info(
          `Updating campaignCharge of charges_campaigns ${donation.campaign_id} failed! Error: ${err}`
        )
      );

    if (donation.useDCs) {
      await firestore
        .collection(DatabaseConstants.user)
        .doc(donation.user_id)
        .collection(DatabaseConstants.advertising_data)
        .doc(DatabaseConstants.ad_balance)
        .set({ dc_balance: increment(-maxDCsToUse) }, { merge: true })
        .catch((err) =>
          functions.logger.info(
            `Updating dc_balance of user ${donation.user_id} failed! Error: ${err}`
          )
        );
      await snapshot.ref.set({ ad_dc_amount: maxDCsToUse }, { merge: true });
    }
  });

exports.onDeleteDonation = functions.firestore
  .document(`${DatabaseConstants.donations}/{donationId}`)
  .onDelete(async (snapshot, context) => {
    const donation: DonationType = snapshot.data() as DonationType;
    console.log(`Deleting ${donation}`);

    await firestore
      .collection(DatabaseConstants.charges_campaigns)
      .doc(donation.campaign_id)
      .update({ amount: increment(-donation.amount) });

    // update the donation amount of the user that created the donation
    await firestore
      .collection(DatabaseConstants.user)
      .doc(donation.user_id)
      .update({
        donated_amount: increment(-donation.amount),
      });

    // update the amounts of donations from the campaign
    await firestore
      .collection(DatabaseConstants.campaigns)
      .doc(donation.campaign_id)
      .update({
        current_amount: increment(-donation.amount),
      });

    // update the daily/monthly/yearly donations
    await firestore
      .collection(DatabaseConstants.statistics)
      .doc(DatabaseConstants.donation_info)
      .update({
        daily_amount: increment(-donation.amount),
        monthly_amount: increment(-donation.amount),
        yearly_amount: increment(-donation.amount),
        donations_count: increment(-1),
        all_donations: increment(-donation.amount),
      });

    // update the donatedAmount in Session Members and session
    if (donation.session_id !== null && donation.session_id !== undefined) {
      await firestore
        .collection(DatabaseConstants.sessions)
        .doc(donation.session_id)
        .collection(DatabaseConstants.session_members)
        .doc(donation.user_id)
        .update({ donation_amount: increment(-donation.amount) });

      await firestore
        .collection(DatabaseConstants.sessions)
        .doc(donation.session_id)
        .update({ current_amount: increment(-donation.amount) });
    }
  });
