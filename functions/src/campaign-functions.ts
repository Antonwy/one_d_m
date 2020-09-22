import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { CampaignType, NewsType } from './types';
import { DatabaseConstants, CampaignFields } from './database-constants';

const firestore = admin.firestore();

exports.onUpdateCampaign = functions.firestore
  .document(`${DatabaseConstants.campaigns}/{campaignId}`)
  .onCreate(async (snapshot, context) => {
    return firestore
      .collection(DatabaseConstants.statistics)
      .doc(DatabaseConstants.campaigns_info)
      .update({ campaign_count: admin.firestore.FieldValue.increment(1) });
  });

exports.onDeleteCampaign = functions.firestore
  .document(`${DatabaseConstants.campaigns}/{campaignId}`)
  .onDelete(async (snapshot, context) => {
    const campaign: CampaignType = snapshot.data() as CampaignType;
    console.log('Deleted Campaign: ', campaign);

    const campaignId: string = context.params.campaignId;

    const bucket = admin.storage().bucket();

    await bucket.deleteFiles({prefix: `campaigns/campaign_${campaignId}/`});

    // delete all news
    const newsQuery = firestore
      .collection(DatabaseConstants.news)
      .where(CampaignFields.campaign_id, '==', campaignId);

    (await newsQuery.get()).forEach(async (doc) => await doc.ref.delete());

    // deleting campaign from users that followed
    const followedUsersQuery = await firestore
      .collection(DatabaseConstants.campaigns_subscribed_users)
      .doc(campaignId)
      .collection(DatabaseConstants.users)
      .get();

    followedUsersQuery.forEach(async (doc) => {
      await doc.ref.delete();
      await firestore
        .collection(DatabaseConstants.subscribed_campaigns)
        .doc(doc.data().id)
        .collection(DatabaseConstants.campaigns)
        .doc(campaignId)
        .delete();
    });

    // deleting all donations
    (
      await firestore
        .collection(DatabaseConstants.donations)
        .where(CampaignFields.campaign_id, '==', campaignId)
        .get()
    ).forEach(async (camp) => await camp.ref.delete());

    // deleting campaign
    await firestore
      .collection(DatabaseConstants.campaigns)
      .doc(campaignId)
      .delete();

    return firestore
      .collection(DatabaseConstants.statistics)
      .doc(DatabaseConstants.campaigns_info)
      .update({ campaign_count: admin.firestore.FieldValue.increment(-1) });
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

      // update news
      const toUpdateNewsQuery = await firestore
        .collection(DatabaseConstants.news)
        .where(CampaignFields.campaign_id, '==', campaignId)
        .get();

      toUpdateNewsQuery.forEach(
        async (doc) => await doc.ref.update(updateValue)
      );

      // update subscribed campaigns
      const subscribedCampaignsUsersQuery = await firestore
        .collection(DatabaseConstants.campaigns_subscribed_users)
        .doc(campaignId)
        .collection(DatabaseConstants.users)
        .get();

      subscribedCampaignsUsersQuery.forEach(async (doc) => {
        await firestore
          .collection(DatabaseConstants.subscribed_campaigns)
          .doc(doc.data().id)
          .collection(DatabaseConstants.subscribed_campaigns)
          .doc(campaignId)
          .update(updateValue);
      });

      // update donations
      const toUpdateDonationsQuery = await firestore
        .collection(DatabaseConstants.donations)
        .where(CampaignFields.campaign_id, '==', campaignId)
        .get();

      toUpdateDonationsQuery.forEach(
        async (doc) => await doc.ref.update(updateValue)
      );
    } else return;
  });

exports.onCreateSubscription = functions.firestore
  .document(
    `${DatabaseConstants.subscribed_campaigns}/{userId}/${DatabaseConstants.campaigns}/{campaignId}`
  )
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
