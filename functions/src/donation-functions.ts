import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { Donation, PrivateUserData } from './types';
import Stripe from 'stripe';
const stripe = new Stripe(functions.config().stripe.token, {
  apiVersion: '2020-03-02',
});

const firestore = admin.firestore();
const increment = admin.firestore.FieldValue.increment;

exports.onCreateDonation = functions
  .region('europe-west3')
  .firestore.document('donations/{donationId}')
  .onCreate(async (snapshot, context) => {
    if (snapshot.data() === undefined) return;

    const donation: Donation = snapshot.data() as Donation;
    const donationId: string = context.params.donationId;

    // update the donation amount of the user that created the donation
    await firestore
      .collection('user')
      .doc(donation.user_id)
      .update({
        donated_amount: increment(donation.amount),
      });

    // update the amounts of donations from the campaign
    await firestore
      .collection('campaigns')
      .doc(donation.campaign_id)
      .update({
        current_amount: increment(donation.amount),
      });

    // update the daily/monthly/yearly donations
    await firestore
      .collection('statistics')
      .doc('donation_info')
      .update({
        daily_amount: increment(donation.amount),
        monthly_amount: increment(donation.amount),
        yearly_amount: increment(donation.amount),
        donations_count: increment(1),
        all_donations: increment(donation.amount),
      });

    // get followed Users of the donation author
    const followedUsers = await firestore
      .collection('followed')
      .doc(donation.user_id)
      .collection('users')
      .get();

    const donationFeedItem: Donation = {
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
        .collection('donation_feed')
        .doc(user.id)
        .collection('donations')
        .doc(donationId)
        .set(donationFeedItem);

      // increment DailyAmount => users in followed FriendRankings
      await firestore
        .collection('donation_feed')
        .doc(user.id)
        .collection('daily_rankings')
        .doc(getDate(donation.created_at.toDate()))
        .collection('users')
        .doc(donation.user_id)
        .set(
          {
            amount: increment(donation.amount),
          },
          { merge: true }
        );

      // increment DailyAmount => CampaignRankings
      await firestore
        .collection('donation_feed')
        .doc(user.id)
        .collection('daily_rankings')
        .doc(getDate(donation.created_at.toDate()))
        .collection('campaigns')
        .doc(donation.campaign_id)
        .set(
          {
            amount: increment(donation.amount),
          },
          { merge: true }
        );

      // increment DailyAmount statistics
      await firestore
        .collection('donation_feed')
        .doc(user.id)
        .collection('daily_rankings')
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
      .collection('donation_feed')
      .doc(donation.user_id)
      .collection('daily_rankings')
      .doc(getDate(donation.created_at.toDate()))
      .collection('users')
      .doc(donation.user_id)
      .set(
        {
          amount: increment(donation.amount),
        },
        { merge: true }
      );

    // increment DailyAmount in own => CampaignRankings
    await firestore
      .collection('donation_feed')
      .doc(donation.user_id)
      .collection('daily_rankings')
      .doc(getDate(donation.created_at.toDate()))
      .collection('campaigns')
      .doc(donation.campaign_id)
      .set(
        {
          amount: increment(donation.amount),
        },
        { merge: true }
      );

    // increment DailyAmount statistics
    await firestore
      .collection('donation_feed')
      .doc(donation.user_id)
      .collection('daily_rankings')
      .doc(getDate(donation.created_at.toDate()))
      .set(
        {
          amount: increment(donation.amount),
        },
        { merge: true }
      );

    const privateUserData: PrivateUserData = (
      await firestore
        .collection('user')
        .doc(donation.user_id)
        .collection('private_data')
        .doc('data')
        .get()
    ).data() as PrivateUserData;

    const paymentMethod = (
      await firestore
        .collection('user')
        .doc(donation.user_id)
        .collection('cards')
        .get()
    ).docs[0];

    await stripe.paymentIntents.create({
      amount: donation.amount * 100,
      currency: 'eur',
      customer: privateUserData.customer_id,
      description: donation.campaign_id,
      payment_method: paymentMethod.id,
      off_session: true,
      confirm: true,
    });
  });

function getDate(nowDate: Date): string {
  return `${nowDate.getFullYear()}-${
    nowDate.getMonth() + 1
  }-${nowDate.getDate()}`;
}

exports.onUpdateDonation = functions.firestore
  .document('donations/{donationId}')
  .onUpdate(async (snapshot, context) => {
    const donationId: string = context.params.donationId;
    const donation: Donation = snapshot.after.data() as Donation;
    console.log(`Updating ${donation}`);

    // get followed Users of the donation author
    const followedUser = await firestore
      .collection('followed')
      .doc(donation.user_id)
      .collection('users')
      .get();

    const donationFeedItem: Donation = {
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
        .collection('donation_feed')
        .doc(user.id)
        .collection('donations')
        .doc(donationId)
        .update(donationFeedItem);
    });
  });

exports.onDeleteDonation = functions.firestore
  .document('donations/{donationId}')
  .onDelete(async (snapshot, context) => {
    const donationId: string = context.params.donationId;
    const donation: Donation = snapshot.data() as Donation;
    console.log(`Deleting ${donation}`);

    if (donationId === 'info') return;

    // get followed Users of the donation author
    const followedUser = await firestore
      .collection('followed')
      .doc(donation.user_id)
      .collection('users')
      .get();

    // delete the donation to the feed of the followed users.
    followedUser.forEach(async (user) => {
      await firestore
        .collection('donation_feed')
        .doc(user.id)
        .collection('donations')
        .doc(donationId)
        .delete();
    });
  });
