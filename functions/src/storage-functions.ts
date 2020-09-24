import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import {
  ImageResolutions,
  ImagePrefix,
  ImageSuffix,
  DatabaseConstants,
  StorageConstants,
} from './database-constants';

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
  const splittedName: string[] = splittedPaths[splittedPaths.length - 1].split(
    '_'
  );
  console.log('SplittedName: ' + splittedName);
  const imageType: ImageType = splittedName[0] as ImageType;
  const resulution: ImageRes = splittedName[splittedName.length - 1].replace(
    ImageSuffix.dottJpg,
    ''
  ) as ImageRes;
  const id = splittedName[1];

  if (imageType === ImagePrefix.news) {
    if (resulution === ImageResolutions.high)
      await firestore
        .collection(DatabaseConstants.news)
        .doc(id)
        .set(
          {
            image_url: generateUrl(obj),
          },
          { merge: true }
        );
  } else if (imageType === ImagePrefix.campaign) {
    if (resulution === ImageResolutions.high)
      await firestore
        .collection(DatabaseConstants.campaigns)
        .doc(id)
        .set(
          {
            image_url: generateUrl(obj),
          },
          { merge: true }
        );
    else
      await firestore
        .collection(DatabaseConstants.campaigns)
        .doc(id)
        .set(
          {
            thumbnail_url: generateUrl(obj),
          },
          { merge: true }
        );
  } else {
    if (resulution === ImageResolutions.high)
      await firestore
        .collection(DatabaseConstants.user)
        .doc(id)
        .set(
          {
            image_url: generateUrl(obj),
          },
          { merge: true }
        );
    else
      await firestore
        .collection(DatabaseConstants.user)
        .doc(id)
        .set(
          {
            thumbnail_url: generateUrl(obj),
          },
          { merge: true }
        );
  }
});

function generateUrl(obj: functions.storage.ObjectMetadata): string {
  return `${StorageConstants.storageUrlStart}${obj.name?.repl(
    new RegExp('/', 'g'),
    '%2F'
  )}${StorageConstants.storageUrlEnd}${
    obj.metadata?.firebaseStorageDownloadTokens ?? ''
  }`;
}
