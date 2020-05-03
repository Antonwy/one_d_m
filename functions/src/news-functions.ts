import * as functions from 'firebase-functions';
// import * as admin from 'firebase-admin';
import { News } from './types';

exports.onDeleteNews = functions.firestore
  .document('news/{newsId}')
  .onDelete(async (snapshot, context) => {
    // const newsId: string = context.params.newsId;
    const news: News = snapshot.data() as News;

    console.log(`Deleting news ${news}`);
  });
