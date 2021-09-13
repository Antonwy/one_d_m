import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import {
  ImageResolutions,
  ImagePrefix,
  ImageSuffix,
  DatabaseConstants,
  StorageConstants,
} from './database-constants';
import { createBlurHash } from './http-functions';
import { getToken, updateAccount } from './api';

const firestore = admin.firestore();

type ImageType = 'news' | 'campaign' | 'user';
type ImageRes = '300x300' | '1080x1920';

exports.onUploadFile = functions.storage.object().onFinalize(async (obj) => {
  if (
    !obj.name?.endsWith(`${ImageResolutions.low}${ImageSuffix.dottJpg}`) &&
    !obj.name?.endsWith(`${ImageResolutions.high}${ImageSuffix.dottJpg}`)
  ) {
    console.log('No valid image!');
    console.log(`Name: ${obj.name}`);
    return;
  }

  console.log('Name: ' + obj.name);

  const splittedPaths: string[] = obj.name.split('/');
  const splittedName: string[] =
    splittedPaths[splittedPaths.length - 1].split('_');
  console.log('SplittedName: ' + splittedName);
  const imageType: ImageType = splittedName[0] as ImageType;
  const resulution: ImageRes = splittedName[splittedName.length - 1].replace(
    ImageSuffix.dottJpg,
    ''
  ) as ImageRes;
  const id = splittedName[1];

  const url = generateUrl(obj);

  if (imageType === ImagePrefix.news) {
    if (resulution === ImageResolutions.high) {
      await firestore
        .collection(DatabaseConstants.news)
        .doc(id)
        .update({
          image_url: url,
          blur_hash: await createBlurHash(url),
        })
        .catch();
    }
  } else if (
    imageType === ImagePrefix.session ||
    imageType === ImagePrefix.certified_sessions
  ) {
    if (resulution === ImageResolutions.high) {
      await firestore
        .collection(DatabaseConstants.sessions)
        .doc(id)
        .update({
          img_url: url,
          blur_hash: await createBlurHash(url),
        })
        .catch();
    }
  } else if (imageType === ImagePrefix.campaign) {
    if (resulution === ImageResolutions.high) {
      await firestore
        .collection(DatabaseConstants.campaigns)
        .doc(id)
        .update({
          image_url: url,
          blur_hash: await createBlurHash(url),
        })
        .catch();
    } else {
      await firestore
        .collection(DatabaseConstants.campaigns)
        .doc(id)
        .update({
          thumbnail_url: url,
        })
        .catch();
    }
  } else if (imageType === ImagePrefix.user) {
    const idToken = await getToken(id);
    if (resulution === ImageResolutions.high) {
      const toUpdateUser = {
        image_url: url,
        blur_hash: await createBlurHash(url),
      };

      await firestore
        .collection(DatabaseConstants.user)
        .doc(id)
        .update(toUpdateUser)
        .catch();

      await updateAccount(toUpdateUser, idToken);
    } else {
      const toUpdateUser = {
        thumbnail_url: url,
      };
      await firestore
        .collection(DatabaseConstants.user)
        .doc(id)
        .update(toUpdateUser)
        .catch();
      await updateAccount(toUpdateUser, idToken);
    }
  }
});

function generateUrl(obj: functions.storage.ObjectMetadata): string {
  return `${StorageConstants.storageUrlStart}${obj.name
    ?.split('/')
    .join('%2F')}${StorageConstants.storageUrlEnd}${
    obj.metadata?.firebaseStorageDownloadTokens ?? ''
  }`;
}
