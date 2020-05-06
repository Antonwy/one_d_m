import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { Campaign } from './types';

exports.onDeleteCampaign = functions.firestore
  .document('campaigns/{campaignId}')
  .onDelete(async (snapshot, context) => {
    const campaign: Campaign = snapshot.data() as Campaign;
    console.log('Deleted Campaign: ', campaign);

    const campaignId: string = context.params.campaignId;

    const imgUrl: string | undefined = getId(campaign.image_url);
    if (imgUrl !== undefined) {
      // deleting campaign image
      await admin.storage().bucket().file(imgUrl).delete();
    }

    const newsQuery = admin
      .firestore()
      .collection('news')
      .where('campaign_id', '==', campaignId);

    // deleting all news
    (await newsQuery.get()).forEach(async (doc) => await doc.ref.delete());

    // deleting campaign from users that followed
    const followedUsersQuery = admin
      .firestore()
      .collection('user')
      .where('subscribed_campaigns', 'array-contains', campaignId);

    (await followedUsersQuery.get()).forEach(
      async (doc) =>
        await doc.ref.update({
          subscribed_campaigns: admin.firestore.FieldValue.arrayRemove(
            campaignId
          ),
        })
    );

    // deleting all donations
    (
      await admin
        .firestore()
        .collection('donations')
        .where('campaign_id', '==', campaignId)
        .get()
    ).forEach(async (camp) => await camp.ref.delete());

    // deleting campaign
    await admin.firestore().collection('campaigns').doc(campaignId).delete();
  });

exports.onUpdateCampaign = functions.firestore
  .document('campaigns/{campaignId}')
  .onUpdate(async (snapshot, context) => {
    const campaignId: string = context.params.campaignId;
    const before: Campaign = snapshot.before.data() as Campaign;
    const after: Campaign = snapshot.after.data() as Campaign;

    if (before.title !== after.title || before.image_url !== after.image_url) {
      // update news
      const toUpdateNewsQuery = admin
        .firestore()
        .collection('news')
        .where('campaign_id', '==', campaignId);

      (await toUpdateNewsQuery.get()).forEach(
        async (doc) =>
          await doc.ref.update({
            campaign_name: after.title,
            campaign_img_url: after.image_url,
          })
      );

      // update donations
      const toUpdateDonationsQuery = admin
        .firestore()
        .collection('donations')
        .where('campaign_id', '==', campaignId);

      (await toUpdateDonationsQuery.get()).forEach(
        async (doc) =>
          await doc.ref.update({
            campaign_name: after.title,
            campaign_img_url: after.image_url,
          })
      );
    } else return;
  });

function getId(url: string): string | undefined {
  let regExp = RegExp('campaign_(.*).jpg');
  let includesUrl: boolean = regExp.test(url);
  if (includesUrl) {
    let exec = regExp.exec(url);
    return exec === null ? undefined : exec[0];
  } else return undefined;
}
