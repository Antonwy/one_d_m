import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

exports.createFollower = functions.firestore
  .document('following/{followedId}/users/{followingId}')
  .onCreate(async (snapshot, context) => {
    console.log('Create Follower', snapshot.data());

    // UserId that followed someone (Anton)
    const followedId = context.params.followedId;
    // UserId that got a new follower (Jordi)
    const followingId = context.params.followingId;

    await admin
      .firestore()
      .collection('followed')
      .doc(followingId)
      .collection('users')
      .doc(followedId)
      .set({ id: followedId });

    const donations = await admin
      .firestore()
      .collection('donations')
      .where('user_id', '==', followingId)
      .get();

    console.log('Copying data to ' + followedId);
    donations.docs.forEach(async (ds) => {
      const donation = ds.data();
      await admin
        .firestore()
        .collection('donation_feed')
        .doc(followedId)
        .collection('donations')
        .add({
          amount: donation.amount,
          user_id: donation.user_id,
          campaign_name: donation.campaign_name,
          campaign_id: donation.campaign_id,
          campaign_img_url: donation.campaign_img_url,
          created_at: donation.created_at,
        });
    });
  });

exports.deleteFollower = functions.firestore
  .document('following/{followedId}/users/{followingId}')
  .onDelete(async (snapshot, context) => {
    console.log('Delete Follower', snapshot.data());

    // UserId that followed someone (Anton)
    const followedId = context.params.followedId;
    // UserId that got a new follower (Jordi)
    const followingId = context.params.followingId;

    await admin
      .firestore()
      .collection('followed')
      .doc(followingId)
      .collection('users')
      .doc(followedId)
      .delete();

    const toDelete = await admin
      .firestore()
      .collection('donation_feed')
      .doc(followedId)
      .collection('donations')
      .where('user_id', '==', followingId)
      .get();

    toDelete.docs.forEach((ds) => ds.ref.delete());
  });
