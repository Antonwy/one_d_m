import * as functions from 'firebase-functions';
import {
  ImageResolutions,
  ImagePrefix,
  ImageSuffix,
  StorageConstants,
} from './database-constants';
import { createBlurHash } from './http-functions';
import { getToken, updateAccount, updateDatabase } from './api';

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
  const img_count: number =
    splittedName.length === 4 ? Number(splittedName[2]) : 0;
  const id = splittedName[1];
  const adminId = 'LEDHRts56FcRwkGM57D6PJQaMoz1';

  const url = generateUrl(obj);

  if (imageType === ImagePrefix.news) {
    const idToken = await getToken(adminId);
    if (resulution === ImageResolutions.high) {
      await updateDatabase(
        'news/' + id,
        {
          image_url: url,
          blur_hash: await createBlurHash(url),
        },
        idToken
      );
    } else {
      await updateDatabase(
        'news/' + id,
        {
          thumbnail_url: url,
        },
        idToken
      );
    }
  } else if (
    imageType === ImagePrefix.session ||
    imageType === ImagePrefix.certified_sessions
  ) {
    const idToken = await getToken(adminId);
    if (resulution === ImageResolutions.high) {
      await updateDatabase(
        'sessions/' + id,
        {
          image_url: url,
          blur_hash: await createBlurHash(url),
        },
        idToken
      );
    } else {
      await updateDatabase(
        'sessions/' + id,
        {
          thumbnail_url: url,
        },
        idToken
      );
    }
  } else if (imageType === ImagePrefix.campaign && img_count === 0) {
    const idToken = await getToken(adminId);
    if (resulution === ImageResolutions.high) {
      await updateDatabase(
        'campaigns/' + id,
        {
          image_url: url,
          blur_hash: await createBlurHash(url),
        },
        idToken
      );
    } else {
      await updateDatabase(
        'campaigns/' + id,
        {
          thumbnail_url: url,
        },
        idToken
      );
    }
  } else if (imageType === ImagePrefix.user) {
    const idToken = await getToken(id);
    if (resulution === ImageResolutions.high) {
      const toUpdateUser = {
        image_url: url,
        blur_hash: await createBlurHash(url),
      };

      await updateAccount(toUpdateUser, idToken);
    } else {
      const toUpdateUser = {
        thumbnail_url: url,
      };
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
