import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { CampaignType, NewsType } from './types';
import { DatabaseConstants, CampaignFields } from './database-constants';

const firestore = admin.firestore();
const increment = admin.firestore.FieldValue.increment;

exports.onCreateCampaign = functions.firestore
  .document(`${DatabaseConstants.campaigns}/{campaignId}`)
  .onCreate(async (snapshot, context) => {
    return firestore
      .collection(DatabaseConstants.statistics)
      .doc(DatabaseConstants.campaigns_info)
      .update({ campaign_count: increment(1) });
  });

exports.onDeleteCampaign = functions.firestore
  .document(`${DatabaseConstants.campaigns}/{campaignId}`)
  .onDelete(async (snapshot, context) => {
    const campaign: CampaignType = snapshot.data() as CampaignType;
    functions.logger.info('Deleted Campaign: ', campaign.id);
    const campaignId: string = context.params.campaignId;

    // deleting campaign from users that followed
    const followedUsersQuery = await firestore
      .collection(DatabaseConstants.campaigns_subscribed_users)
      .doc(campaignId).collection(DatabaseConstants.users).get();
    functions.logger.info(campaignId + " has :" + followedUsersQuery.docs.length + " subscribed users");
    followedUsersQuery.forEach(async (doc) => {
      await doc.ref.delete().then(() => { functions.logger.info(doc.id + ": deleted"); }).catch((e) => { functions.logger.error(e) })
      // deletion of subscribed_campaigns/{userId}/campaigns/{campaignId}
      await firestore.collection(DatabaseConstants.subscribed_campaigns).doc(doc.data().id)
        .collection(DatabaseConstants.campaigns).doc(campaignId).delete();
    });

    // updating charges_campaigns with deleted status
    await firestore.collection(DatabaseConstants.charges_campaigns)
      .doc(campaignId).update({ "deleted": true })
      .then(() => { functions.logger.info(DatabaseConstants.charges_campaigns + " : " + campaignId + " updates wit delete status") })
      .catch(e => { functions.logger.info(e) })

    // decrease the campaign count nu one from statistics/campaign_info/campaign_count
    await firestore.collection(DatabaseConstants.statistics).doc(DatabaseConstants.campaigns_info)
      .update({ campaign_count: admin.firestore.FieldValue.increment(-1) })
      .then(() => { functions.logger.info("campaign info count decrease by one") })
      .catch((e) => { functions.logger.info(e) })

    // delete all news where campaign id is equival to campaignId
    firestore.collection(DatabaseConstants.news)
      .where(CampaignFields.campaign_id, '==', campaignId).get().then(newSnapshot => {
        newSnapshot.docs.forEach(async doc => await doc.ref.delete())
      }).catch(e => { functions.logger.info(e) });

    // delete all sessions and data inside sub collections where campaign id is equival to campaignId
    const campaignSessions = firestore.collection(DatabaseConstants.sessions).where(CampaignFields.campaign_id, '==', campaignId);
    await campaignSessions.get().then(async (sessions) => {
      sessions.docs.forEach(async (doc) => {
        await doc.ref.listCollections().then(async list => {
          console.log("subcollections length:" + list.length);
          list.forEach(async (collection) => {
            await collection.get().then(async col_docs => {
              col_docs.docs.forEach(async col_doc => { await col_doc.ref.delete(); })
            })
          })
        }).catch(e => { functions.logger.info(e) })
        await doc.ref.delete();
      })
    }).catch(e => { functions.logger.info(e) })
    // deleting images of campaign
    const bucket = admin.storage().bucket();
    await bucket.deleteFiles({ prefix: `campaigns/campaign_${campaignId}/` })
      .then(() => { functions.logger.info("File deleted successfully") })
      .catch(e => { functions.logger.info(e) });
    return "Ok";
  });

exports.onUpdateCampaign = functions.firestore
  .document(`${DatabaseConstants.campaigns}/{campaignId}`)
  .onUpdate(async (snapshot, context) => {
    const campaignId: string = context.params.campaignId;
    const before: CampaignType = snapshot.before.data() as CampaignType;
    const after: CampaignType = snapshot.after.data() as CampaignType;

    if (before.title !== after.title || before.image_url !== after.image_url) {
      const updateValue = {
        campaign_name: after.title,
        campaign_img_url: after.image_url,
      };
      // update donations
      const toUpdateDonationsQuery = await firestore
        .collection(DatabaseConstants.donations)
        .where(CampaignFields.campaign_id, '==', campaignId)
        .get();
      toUpdateDonationsQuery.docs.forEach(
        async (doc) => await doc.ref.update(updateValue)
      );
      // update news
      const toUpdateNewsQuery = await firestore
        .collection(DatabaseConstants.news)
        .where(CampaignFields.campaign_id, '==', campaignId)
        .get();
      functions.logger.info("news found to update:" + toUpdateNewsQuery.docs.length)
      toUpdateNewsQuery.docs.forEach(
        async (doc) => await doc.ref.update(updateValue)
      );
      // delete old image_url
      if (before.image_url !== undefined && before.image_url !== after.image_url) {
        const bucket = admin.storage().bucket();
        const image_path = "campaigns/campaign_" + campaignId + "/campaign_" + campaignId + "_0";
        await bucket.file(image_path + ".jpg").delete()
        await bucket.file(image_path + "_1080x1920.jpg").delete()
        await bucket.file(image_path + "_300x300.jpg").delete()
      }
      // update sessions
      await firestore.collection(DatabaseConstants.sessions).where(CampaignFields.campaign_id, '==', campaignId)
        .get().then(async sessions => {
          functions.logger.info("sessions found to update:" + sessions.docs.length)
          sessions.docs.forEach(async doc => { await doc.ref.update(updateValue) })
        })
      // update subscribed campaigns
      const subscribedCampaignsUsersQuery = await firestore
        .collection(DatabaseConstants.campaigns_subscribed_users)
        .doc(campaignId)
        .collection(DatabaseConstants.users)
        .get();
      functions.logger.info("subscribed users to update:" + subscribedCampaignsUsersQuery.docs.length)

      subscribedCampaignsUsersQuery.forEach(async (doc) => {
        await firestore
          .collection(DatabaseConstants.subscribed_campaigns)
          .doc(doc.data().id)
          .collection(DatabaseConstants.subscribed_campaigns)
          .doc(campaignId)
          .update(updateValue);
      });
    } else return;
  });

exports.onCreateSubscription = functions.firestore
  .document(`${DatabaseConstants.subscribed_campaigns}/{userId}/${DatabaseConstants.campaigns}/{campaignId}`)
  .onCreate(async (snapshot, context) => {
    const userId = context.params.userId;
    const campaignId = context.params.campaignId;

    await firestore
      .collection(DatabaseConstants.campaigns)
      .doc(campaignId)
      .update({ subscribed_count: admin.firestore.FieldValue.increment(1) });

    await firestore
      .collection(DatabaseConstants.campaigns_subscribed_users)
      .doc(campaignId)
      .collection(DatabaseConstants.users)
      .doc(userId)
      .set({ id: userId });

    const campaignNews = await firestore
      .collection(DatabaseConstants.news)
      .where(CampaignFields.campaign_id, '==', campaignId)
      .get();

    campaignNews.forEach(async (doc) => {
      const news: NewsType = doc.data() as NewsType;
      await firestore
        .collection(DatabaseConstants.news_feed)
        .doc(userId)
        .collection(DatabaseConstants.news)
        .add({
          campaign_id: news.campaign_id,
          campaign_img_url: news.campaign_img_url,
          campaign_name: news.campaign_name,
          created_at: news.created_at,
          image_url: news.image_url,
          short_text: news.short_text,
          text: news.text,
          title: news.title,
          user_id: news.user_id,
        });
    });
  });

exports.onDeleteSubscription = functions.firestore
  .document(
    `${DatabaseConstants.subscribed_campaigns}/{userId}/${DatabaseConstants.campaigns}/{campaignId}`
  )
  .onDelete(async (snapshot, context) => {
    const userId = context.params.userId;
    const campaignId = context.params.campaignId;

    await firestore
      .collection(DatabaseConstants.campaigns)
      .doc(campaignId)
      .update({ subscribed_count: admin.firestore.FieldValue.increment(-1) });

    await firestore
      .collection(DatabaseConstants.campaigns_subscribed_users)
      .doc(campaignId)
      .collection(DatabaseConstants.users)
      .doc(userId)
      .delete();

    const campaignNews = await firestore
      .collection(DatabaseConstants.news_feed)
      .doc(userId)
      .collection(DatabaseConstants.news)
      .where(CampaignFields.campaign_id, '==', campaignId)
      .get();

    campaignNews.forEach(async (doc) => {
      await doc.ref.delete();
    });
  });

