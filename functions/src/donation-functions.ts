import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { Donation } from './types';

exports.onCreateDonation = functions.firestore
  .document('donations/{donationId}')
  .onCreate(async (snapshot, context) => {
    if (snapshot.data() === undefined) return;

    const donation: Donation = snapshot.data() as Donation;

    // update the donation amount of the user that created the donation
    await admin
      .firestore()
      .collection('user')
      .doc(donation.user_id)
      .update({
        donated_amount: admin.firestore.FieldValue.increment(donation.amount),
      });

    // update the amounts of donations from the campaign
    await admin
      .firestore()
      .collection('campaigns')
      .doc(donation.campaign_id)
      .update({
        current_amount: admin.firestore.FieldValue.increment(donation.amount),
      });

    // update the daily/monthly/yearly donations
    await admin
      .firestore()
      .collection('donations')
      .doc('info')
      .update({
        daily_amount: admin.firestore.FieldValue.increment(donation.amount),
        monthly_amount: admin.firestore.FieldValue.increment(donation.amount),
        yearly_amount: admin.firestore.FieldValue.increment(donation.amount),
      });

    // get followed Users of the donation author
    const followedUser = await admin
      .firestore()
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
    };

    // add the donation to the feed of the followed users.
    followedUser.docs.forEach(async (user) => {
      await admin
        .firestore()
        .collection('donation_feed')
        .doc(user.id)
        .collection('donations')
        .doc(context.params.donationId)
        .set(donationFeedItem);
    });
  });

exports.onUpdateDonation = functions.firestore
  .document('donations/{donationId}')
  .onUpdate(async (snapshot, context) => {
    const donationId: string = context.params.donationId;
    const donation: Donation = snapshot.after.data() as Donation;
    console.log(`Updating ${donation}`);

    if (donationId == 'info') return;

    // get followed Users of the donation author
    const followedUser = await admin
      .firestore()
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
    };

    // add the donation to the feed of the followed users.
    followedUser.forEach(async (user) => {
      await admin
        .firestore()
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

    if (donationId == 'info') return;

    // get followed Users of the donation author
    const followedUser = await admin
      .firestore()
      .collection('followed')
      .doc(donation.user_id)
      .collection('users')
      .get();

    // delete the donation to the feed of the followed users.
    followedUser.forEach(async (user) => {
      await admin
        .firestore()
        .collection('donation_feed')
        .doc(user.id)
        .collection('donations')
        .doc(donationId)
        .delete();
    });
  });
