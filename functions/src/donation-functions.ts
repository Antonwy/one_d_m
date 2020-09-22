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
    const donationId: string = context.params.donationId;

    // update the donation amount of the user that created the donation
    await firestore
      .collection(DatabaseConstants.user)
      .doc(donation.user_id)
      .update({
        donated_amount: increment(donation.amount),
      });

    // update the amounts of donations from the campaign
    await firestore
      .collection(DatabaseConstants.campaigns)
      .doc(donation.campaign_id)
      .update({
        current_amount: increment(donation.amount),
      });

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
      });

    // get followed Users of the donation author
    const followedUsers = await firestore
      .collection(DatabaseConstants.followed)
      .doc(donation.user_id)
      .collection(DatabaseConstants.users)
      .get();

    const donationFeedItem: DonationType = {
      amount: donation.amount,
      user_id: donation.user_id,
      campaign_name: donation.campaign_name,
      campaign_id: donation.campaign_id,
      created_at: donation.created_at,
      campaign_img_url: donation.campaign_img_url,
      anonym: donation?.anonym,
    };

    followedUsers.forEach(async (user) => {
      // add the donation to the feed of the followed users
      await firestore
        .collection(DatabaseConstants.donation_feed)
        .doc(user.id)
        .collection(DatabaseConstants.donations)
        .doc(donationId)
        .set(donationFeedItem);

      // increment DailyAmount => users in followed FriendRankings
      await firestore
        .collection(DatabaseConstants.donation_feed)
        .doc(user.id)
        .collection(DatabaseConstants.daily_rankings)
        .doc(getDate(donation.created_at.toDate()))
        .collection(DatabaseConstants.users)
        .doc(donation.user_id)
        .set(
          {
            amount: increment(donation.amount),
          },
          { merge: true }
        );

      // increment DailyAmount => CampaignRankings
      await firestore
        .collection(DatabaseConstants.donation_feed)
        .doc(user.id)
        .collection(DatabaseConstants.daily_rankings)
        .doc(getDate(donation.created_at.toDate()))
        .collection(DatabaseConstants.campaigns)
        .doc(donation.campaign_id)
        .set(
          {
            amount: increment(donation.amount),
          },
          { merge: true }
        );

      // increment DailyAmount statistics
      await firestore
        .collection(DatabaseConstants.donation_feed)
        .doc(user.id)
        .collection(DatabaseConstants.daily_rankings)
        .doc(getDate(donation.created_at.toDate()))
        .set(
          {
            amount: increment(donation.amount),
          },
          { merge: true }
        );
    });

    // increment DailyAmount in own => users FriendRanking
    await firestore
      .collection(DatabaseConstants.donation_feed)
      .doc(donation.user_id)
      .collection(DatabaseConstants.daily_rankings)
      .doc(getDate(donation.created_at.toDate()))
      .collection(DatabaseConstants.users)
      .doc(donation.user_id)
      .set(
        {
          amount: increment(donation.amount),
        },
        { merge: true }
      );

    // increment DailyAmount in own => CampaignRankings
    await firestore
      .collection(DatabaseConstants.donation_feed)
      .doc(donation.user_id)
      .collection(DatabaseConstants.daily_rankings)
      .doc(getDate(donation.created_at.toDate()))
      .collection(DatabaseConstants.campaigns)
      .doc(donation.campaign_id)
      .set(
        {
          amount: increment(donation.amount),
        },
        { merge: true }
      );

    // increment DailyAmount statistics
    await firestore
      .collection(DatabaseConstants.donation_feed)
      .doc(donation.user_id)
      .collection(DatabaseConstants.daily_rankings)
      .doc(getDate(donation.created_at.toDate()))
      .set(
        {
          amount: increment(donation.amount),
        },
        { merge: true }
      );

    const userCharge: ChargesType = {
      amount: increment(donation.amount),
      user_id: donation.user_id,
      error: false,
    };

    const campaignCharge: ChargesType = {
      amount: increment(donation.amount),
      campaign_id: donation.campaign_id,
    };

    await firestore
      .collection(DatabaseConstants.charges_campaigns)
      .doc(donation.campaign_id)
      .set(campaignCharge, { merge: true });

    await firestore
      .collection(DatabaseConstants.charges_users)
      .doc(donation.user_id)
      .set(userCharge, { merge: true });
  });

function getDate(nowDate: Date): string {
  return `${nowDate.getFullYear()}-${
    nowDate.getMonth() + 1
  }-${nowDate.getDate()}`;
}

exports.onUpdateDonation = functions.firestore
  .document(`${DatabaseConstants.donations}/{donationId}`)
  .onUpdate(async (snapshot, context) => {
    const donationId: string = context.params.donationId;
    const donation: DonationType = snapshot.after.data() as DonationType;
    console.log(`Updating ${donation}`);

    // get followed Users of the donation author
    const followedUser = await firestore
      .collection(DatabaseConstants.followed)
      .doc(donation.user_id)
      .collection(DatabaseConstants.users)
      .get();

    const donationFeedItem: DonationType = {
      amount: donation.amount,
      user_id: donation.user_id,
      campaign_name: donation.campaign_name,
      campaign_id: donation.campaign_id,
      created_at: donation.created_at,
      campaign_img_url: donation.campaign_img_url,
      anonym: donation.anonym,
    };

    // add the donation to the feed of the followed users.
    followedUser.forEach(async (user) => {
      await firestore
        .collection(DatabaseConstants.donation_feed)
        .doc(user.id)
        .collection(DatabaseConstants.donations)
        .doc(donationId)
        .update(donationFeedItem);
    });
  });

exports.onDeleteDonation = functions.firestore
  .document(`${DatabaseConstants.donations}/{donationId}`)
  .onDelete(async (snapshot, context) => {
    const donationId: string = context.params.donationId;
    const donation: DonationType = snapshot.data() as DonationType;
    console.log(`Deleting ${donation}`);

    // get followed Users of the donation author
    const followedUser = await firestore
      .collection(DatabaseConstants.followed)
      .doc(donation.user_id)
      .collection(DatabaseConstants.users)
      .get();

    // delete the donation to the feed of the followed users.
    followedUser.forEach(async (user) => {
      await firestore
        .collection(DatabaseConstants.donation_feed)
        .doc(user.id)
        .collection(DatabaseConstants.donations)
        .doc(donationId)
        .delete();
    });
  });
