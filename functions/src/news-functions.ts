import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { NewsType } from './types';
import {
  DatabaseConstants,
  ImageResolutions,
  ImageSuffix,
} from './database-constants';

exports.onDeleteNews = functions.firestore
  .document(`${DatabaseConstants.news}/{newsId}`)
  .onDelete(async (snapshot, context) => {
    const news: NewsType = snapshot.data() as NewsType;
    const newsId: string = context.params.newsId;

    console.log(`Deleting news ${news}`);

    const bucket = admin.storage().bucket();
    await bucket
      .deleteFiles({ prefix: `news/news_${newsId}/` })
      .then(() => {
        functions.logger.info('File deleted successfully');
      })
      .catch((e) => {
        functions.logger.info(e);
      });
  });

exports.onUpdateNews = functions.firestore
  .document(`${DatabaseConstants.news}/{newsId}`)
  .onUpdate(async (snapshot, context) => {
    const beforeNews: NewsType = snapshot.before.data() as NewsType;
    const news: NewsType = snapshot.after.data() as NewsType;
    const newsId: string = context.params.newsId;

    functions.logger.info(`Updating news ${news}`);

    if (
      beforeNews.image_url !== undefined &&
      beforeNews.image_url !== news.image_url &&
      beforeNews.image_url.endsWith(
        `${ImageResolutions.high}${ImageSuffix.dottJpg}`
      )
    ) {
      functions.logger.info('Delete image of news');
      const bucket = admin.storage().bucket();
      const image_path = 'news/news_' + newsId + '/';
      await bucket.deleteFiles({
        prefix: image_path,
      });
    }
  });
