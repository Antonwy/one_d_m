const functions = require('firebase-functions');
const admin = require('firebase-admin');
const firebase = admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

exports.onCreateSubscription = functions.firestore
  .document('/subscribed_campaigns/{userId}/campaigns/{campaignId}')
  .onCreate(async (snapshot, context) => {
    const userId = context.params.userId;
    const campaignId = context.params.campaignId;

    console.log('Subscribed campaign: ', snapshot.data());

    const campaignNewsRef = admin
      .firestore()
      .collection('news')
      .doc(campaignId)
      .collection('campaign_news');

    const feedRef = admin
      .firestore()
      .collection('feed')
      .doc(userId)
      .collection('news');

    const user = await admin
      .firestore()
      .collection('user')
      .doc(userId)
      .get();

    await admin
      .firestore()
      .collection('campaign_subscriptions')
      .doc(campaignId)
      .collection('users')
      .doc(userId)
      .set(user.data());

    const querySnapshot = await campaignNewsRef.get();

    querySnapshot.forEach(doc => {
      feedRef.doc(doc.id).set(doc.data());
    });
  });

exports.onDeleteSubscription = functions.firestore
  .document('/subscribed_campaigns/{userId}/campaigns/{campaignId}')
  .onDelete(async (snapshot, context) => {
    console.log('Deleting Subscription: ', snapshot.data());

    const userId = context.params.userId;
    const campaignId = context.params.campaignId;

    const feedRef = admin
      .firestore()
      .collection('feed')
      .doc(userId)
      .collection('news')
      .where('campaign_id', '==', campaignId);

    admin
      .firestore()
      .collection('campaign_subscriptions')
      .doc(campaignId)
      .collection('user')
      .doc(userId)
      .delete();

    const querySnapshot = await feedRef.get();

    querySnapshot.forEach(doc => {
      if (doc.exists) doc.ref.delete();
    });
  });

exports.onDeleteCampaign = functions.firestore
  .document('campaigns/{campaignId}')
  .onDelete(async (snapshot, context) => {
    console.log('Deleted Campaign: ', snapshot.data());

    const campaignId = context.params.campaignId;

    const campaignSubscriptionRef = admin
      .firestore()
      .collection('campaign_subscriptions');

    const subscribedUsersRef = campaignSubscriptionRef
      .doc(campaignId)
      .collection('users');

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
      .doc(campaignId)
      .delete();

    campaignSubscriptionRef.doc(campaignId).delete();

    const querySnapshot = await subscribedUsersRef.get();

    await campaignSubscriptionRef.doc(campaignId).delete();

    querySnapshot.forEach(doc => {
      admin
        .firestore()
        .collection('subscribed_campaigns')
        .doc(doc.id)
        .collection('campaigns')
        .doc(campaignId)
        .delete();
    });
  });

getId = url => {
  const regExp = RegExp('campaign_(.*).jpg');
  return regExp.test(url) ? regExp.exec(url)[0] : null;
};

exports.onCreateNews = functions.firestore
  .document('news/{campaignId}/campaign_news/{newsId}')
  .onCreate(async (snapshot, context) => {
    const campaignId = context.params.campaignId;
    const newsId = context.params.newsId;

    console.log('Creating Post: ', snapshot.data());

    const campaignSubscriptionRef = admin
      .firestore()
      .collection('campaign_subscriptions')
      .doc(campaignId)
      .collection('users');

    const querySnapshot = await campaignSubscriptionRef.get();

    querySnapshot.forEach(doc => {
      admin
        .firestore()
        .collection('feed')
        .doc(doc.id)
        .collection('news')
        .doc(newsId)
        .set(snapshot.data());
    });
  });

exports.createFollower = functions.firestore
  .document('following/{followedId}/users/{followingId}')
  .onCreate(async (snapshot, context) => {
    console.log('Create Follower', snapshot.data());

    // UserId that followed someone (Anton)
    const followedId = context.params.followedId;
    // UserId that got a new follower (Jordi)
    const followingId = context.params.followingId;

    const followedUser = await admin
      .firestore()
      .collection('user')
      .doc(followedId)
      .get();

    admin
      .firestore()
      .collection('followed')
      .doc(followingId)
      .collection('users')
      .doc(followedId)
      .set(followedUser.data());
  });

exports.deleteFollower = functions.firestore
  .document('following/{followedId}/users/{followingId}')
  .onDelete(async (snapshot, context) => {
    console.log('Delete Follower', snapshot.data());

    // UserId that followed someone (Anton)
    const followedId = context.params.followedId;
    // UserId that got a new follower (Jordi)
    const followingId = context.params.followingId;

    admin
      .firestore()
      .collection('followed')
      .doc(followingId)
      .collection('users')
      .doc(followedId)
      .delete();
  });
