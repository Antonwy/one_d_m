import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { NewsType } from './types';
import { DatabaseConstants } from './database-constants';

const firestore = admin.firestore();

exports.onCreateNews = functions.firestore
  .document(`${DatabaseConstants.news}/{newsId}`)
  .onCreate(async (snapshot, context) => {
    const news: NewsType = snapshot.data() as NewsType;
    const newsId: string = context.params.newsId;

    const subscribedUsers = await firestore
      .collection(DatabaseConstants.campaigns_subscribed_users)
      .doc(news.campaign_id)
      .collection(DatabaseConstants.users)
      .get();

    subscribedUsers.forEach(async (doc) => {
      await firestore
        .collection(DatabaseConstants.news_feed)
        .doc(doc.data().id)
        .collection(DatabaseConstants.news)
        .doc(newsId)
        .set({
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

exports.onDeleteNews = functions.firestore
  .document(`${DatabaseConstants.news}/{newsId}`)
  .onDelete(async (snapshot, context) => {
    const news: NewsType = snapshot.data() as NewsType;
    const newsId: string = context.params.newsId;

    console.log(`Deleting news ${news}`);

    const subscribedUsers = await firestore
      .collection(DatabaseConstants.campaigns_subscribed_users)
      .doc(news.campaign_id)
      .collection(DatabaseConstants.users)
      .get();

    subscribedUsers.forEach(async (doc) => {
      await firestore
        .collection(DatabaseConstants.news_feed)
        .doc(doc.data().id)
        .collection(DatabaseConstants.news)
        .doc(newsId)
        .delete();
    });
  });

exports.onUpdateNews = functions.firestore
  .document(`${DatabaseConstants.news}/{newsId}`)
  .onUpdate(async (snapshot, context) => {
    const news: NewsType = snapshot.after.data() as NewsType;
    const newsId: string = context.params.newsId;

    console.log(`Deleting news ${news}`);

    const subscribedUsers = await firestore
      .collection(DatabaseConstants.campaigns_subscribed_users)
      .doc(news.campaign_id)
      .collection(DatabaseConstants.users)
      .get();

    subscribedUsers.forEach(async (doc) => {
      await firestore
        .collection(DatabaseConstants.news_feed)
        .doc(doc.data().id)
        .collection(DatabaseConstants.news)
        .doc(newsId)
        .set({
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
