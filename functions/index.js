const functions = require('firebase-functions');
const admin = require('firebase-admin');
const firebase = admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

exports.onCreateDonation = functions.firestore
  .document('donations/{donationId}')
  .onCreate(async (snapshot, context) => {
    const donation = snapshot.data();

    console.log(donation);

    const usersQs = await admin
      .firestore()
      .collection('followed')
      .doc(donation.user_id)
      .collection('users')
      .get();

    await admin
      .firestore()
      .collection('user')
      .doc(donation.user_id)
      .update({
        donated_amount: admin.firestore.FieldValue.increment(donation.amount)
      });

    await admin
      .firestore()
      .collection('campaigns')
      .doc(donation.campaign_id)
      .update({
        current_amount: admin.firestore.FieldValue.increment(donation.amount)
      });

    await admin
      .firestore()
      .collection('donations')
      .doc('info')
      .update({
        daily_amount: admin.firestore.FieldValue.increment(donation.amount),
        monthly_amount: admin.firestore.FieldValue.increment(donation.amount),
        yearly_amount: admin.firestore.FieldValue.increment(donation.amount)
      });

    usersQs.docs.forEach(async ds => {
      await admin
        .firestore()
        .collection('donation_feed')
        .doc(ds.id)
        .collection('donations')
        .add({
          amount: donation.amount,
          user_id: donation.user_id,
          campaign_name: donation.campaign_name,
          campaign_id: donation.campaign_id,
          created_at: donation.created_at
        });
    });
  });

exports.onDeleteCampaign = functions.firestore
  .document('campaigns/{campaignId}')
  .onDelete(async (snapshot, context) => {
    console.log('Deleted Campaign: ', snapshot.data());

    const campaignId = context.params.campaignId;

    const id = getId(snapshot.data().image_url);
    if (id !== null) {
      firebase
        .storage()
        .bucket()
        .file(id)
        .delete();
    }

    admin
      .firestore()
      .collection('news')
      .where('campaign_id', '==', campaignId)
      .delete();

    admin
      .firestore()
      .collection('campaigns')
      .doc(campaignId)
      .delete();
  });

getId = url => {
  const regExp = RegExp('campaign_(.*).jpg');
  return regExp.test(url) ? regExp.exec(url)[0] : null;
};

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
    donations.docs.forEach(async ds => {
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
          created_at: donation.created_at
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

    toDelete.docs.forEach(ds => ds.ref.delete());
  });
