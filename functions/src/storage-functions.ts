import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const firestore = admin.firestore();

exports.onUploadFile = functions.storage.object().onFinalize(async (obj) => {
  if (
    !obj.name?.endsWith('300x300.jpg') &&
    !obj.name?.endsWith('1080x1920.jpg')
  ) {
    console.log('No valid image!');
    console.log(`Name: ${obj.name}`);
    return;
  }

  const splittedName: string[] = obj.name.split('_');
  const imageType: 'news' | 'campaign' | 'user' = splittedName[0] as
    | 'news'
    | 'campaign'
    | 'user';
  const resulution: '300x300' | '1080x1920' = splittedName[2].replace(
    '.jpg',
    ''
  ) as '300x300' | '1080x1920';
  const id = splittedName[1];

  if (imageType === 'news') {
    if (resulution == '1080x1920')
      await firestore
        .collection('news')
        .doc(id)
        .set(
          {
            image_url: generateUrl(obj),
          },
          { merge: true }
        );
  } else if (imageType === 'campaign') {
    if (resulution == '1080x1920')
      await firestore
        .collection('campaigns')
        .doc(id)
        .set(
          {
            image_url: generateUrl(obj),
          },
          { merge: true }
        );
    else
      await firestore
        .collection('campaigns')
        .doc(id)
        .set(
          {
            thumbnail_url: generateUrl(obj),
          },
          { merge: true }
        );
  } else {
    if (resulution == '1080x1920')
      await firestore
        .collection('user')
        .doc(id)
        .set(
          {
            image_url: generateUrl(obj),
          },
          { merge: true }
        );
    else
      await firestore
        .collection('user')
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
  return `https://firebasestorage.googleapis.com/v0/b/one-dollar-movement.appspot.com/o/${
    obj.name
  }?alt=media&token=${obj.metadata?.firebaseStorageDownloadTokens ?? ''}`;
}
