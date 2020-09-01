import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { UserType } from './types';
import { DatabaseConstants, DonationFields } from './database-constants';

const firestore = admin.firestore();

exports.createFollower = functions.firestore
  .document(
    `${DatabaseConstants.following}/{followedId}/${DatabaseConstants.users}/{followingId}`
  )
  .onCreate(async (snapshot, context) => {
    console.log('Create Follower', snapshot.data());

    // UserId that followed someone (Anton)
    const followedId = context.params.followedId;
    // UserId that got a new follower (Jordi)
    const followingId = context.params.followingId;

    await firestore
      .collection(DatabaseConstants.followed)
      .doc(followingId)
      .collection(DatabaseConstants.users)
      .doc(followedId)
      .set({ id: followedId });

    const donations = await firestore
      .collection(DatabaseConstants.donations)
      .where(DonationFields.user_id, '==', followingId)
      .get();

    console.log('Copying data to ' + followedId);
    donations.docs.forEach(async (ds) => {
      const donation = ds.data();
      await firestore
        .collection(DatabaseConstants.donation_feed)
        .doc(followedId)
        .collection(DatabaseConstants.donations)
        .add({
          amount: donation.amount,
          user_id: donation.user_id,
          campaign_name: donation.campaign_name,
          campaign_id: donation.campaign_id,
          campaign_img_url: donation.campaign_img_url,
          created_at: donation.created_at,
        });
    });

    const privateData = await firestore
      .collection(DatabaseConstants.user)
      .doc(followingId)
      .collection(DatabaseConstants.private_data)
      .doc(DatabaseConstants.data)
      .get();

    const followedUser: UserType = (
      await firestore.collection(DatabaseConstants.user).doc(followedId).get()
    ).data() as UserType;

    const data = privateData.data();
    const deviceToken: string | undefined = data?.device_token;

    console.log(data);

    if (
      data === undefined ||
      deviceToken === undefined ||
      deviceToken === null ||
      deviceToken.length === 0
    )
      return;

    const payload = {
      notification: {
        title: 'Du hast einen neuen Follower!',
        body: `${followedUser.name} folgt dir jetzt.`,
        icon:
          followedUser?.image_url === null ? undefined : followedUser.image_url,
      },
    };

    console.log(deviceToken, payload);

    const sendRes = await admin.messaging().sendToDevice(deviceToken, payload);

    console.log(sendRes);
  });

exports.deleteFollower = functions.firestore
  .document(
    `${DatabaseConstants.following}/{followedId}/${DatabaseConstants.users}/{followingId}`
  )
  .onDelete(async (snapshot, context) => {
    console.log('Delete Follower', snapshot.data());

    // UserId that followed someone (Anton)
    const followedId = context.params.followedId;
    // UserId that got a new follower (Jordi)
    const followingId = context.params.followingId;

    await firestore
      .collection(DatabaseConstants.followed)
      .doc(followingId)
      .collection(DatabaseConstants.users)
      .doc(followedId)
      .delete();

    const toDelete = await firestore
      .collection(DatabaseConstants.donation_feed)
      .doc(followedId)
      .collection(DatabaseConstants.donations)
      .where(DonationFields.user_id, '==', followingId)
      .get();

    toDelete.docs.forEach(async (ds) => await ds.ref.delete());
  });
