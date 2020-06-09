import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { User } from './types';

const firestore = admin.firestore();

exports.createFollower = functions.firestore
  .document('following/{followedId}/users/{followingId}')
  .onCreate(async (snapshot, context) => {
    console.log('Create Follower', snapshot.data());

    // UserId that followed someone (Anton)
    const followedId = context.params.followedId;
    // UserId that got a new follower (Jordi)
    const followingId = context.params.followingId;

    await firestore
      .collection('followed')
      .doc(followingId)
      .collection('users')
      .doc(followedId)
      .set({ id: followedId });

    const donations = await firestore
      .collection('donations')
      .where('user_id', '==', followingId)
      .get();

    console.log('Copying data to ' + followedId);
    donations.docs.forEach(async (ds) => {
      const donation = ds.data();
      await firestore
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

    const privateData = await firestore
      .collection('user')
      .doc(followingId)
      .collection('private_data')
      .doc('data')
      .get();

    const followedUser: User = (
      await firestore.collection('user').doc(followedId).get()
    ).data() as User;

    const data = privateData.data();
    const deviceToken: string | undefined = data?.device_token;

    console.log(data);

    if (
      data === undefined ||
      deviceToken === undefined ||
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
  .document('following/{followedId}/users/{followingId}')
  .onDelete(async (snapshot, context) => {
    console.log('Delete Follower', snapshot.data());

    // UserId that followed someone (Anton)
    const followedId = context.params.followedId;
    // UserId that got a new follower (Jordi)
    const followingId = context.params.followingId;

    await firestore
      .collection('followed')
      .doc(followingId)
      .collection('users')
      .doc(followedId)
      .delete();

    const toDelete = await firestore
      .collection('donation_feed')
      .doc(followedId)
      .collection('donations')
      .where('user_id', '==', followingId)
      .get();

    toDelete.docs.forEach(async (ds) => await ds.ref.delete());
  });
