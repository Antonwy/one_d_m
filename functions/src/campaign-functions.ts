import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { CampaignType } from './types';
import {
  DatabaseConstants,
  CampaignFields,
  ImageResolutions,
  ImageSuffix,
  DonationFields,
} from './database-constants';

const firestore = admin.firestore();
const increment = admin.firestore.FieldValue.increment;
const bucket = admin.storage().bucket();

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
      .doc(campaignId)
      .collection(DatabaseConstants.users)
      .get();

    functions.logger.info(
      campaignId +
        ' has :' +
        followedUsersQuery.docs.length +
        ' subscribed users'
    );

    for await (const doc of followedUsersQuery.docs) {
      await doc.ref
        .delete()
        .then(() => {
          functions.logger.info(doc.id + ': deleted');
        })
        .catch((e) => {
          functions.logger.error(e);
        });
      // deletion of subscribed_campaigns/{userId}/campaigns/{campaignId}
      await firestore
        .collection(DatabaseConstants.subscribed_campaigns)
        .doc(doc.data().id)
        .collection(DatabaseConstants.campaigns)
        .doc(campaignId)
        .delete();
    }

    // updating charges_campaigns with deleted status
    await firestore
      .collection(DatabaseConstants.charges_campaigns)
      .doc(campaignId)
      .update({ deleted: true })
      .then(() => {
        functions.logger.info(
          DatabaseConstants.charges_campaigns +
            ' : ' +
            campaignId +
            ' updates wit delete status'
        );
      })
      .catch((e) => {
        functions.logger.info(e);
      });

    // decrease the campaign count nu one from statistics/campaign_info/campaign_count
    await firestore
      .collection(DatabaseConstants.statistics)
      .doc(DatabaseConstants.campaigns_info)
      .update({ campaign_count: admin.firestore.FieldValue.increment(-1) })
      .then(() => {
        functions.logger.info('campaign info count decrease by one');
      })
      .catch((e) => {
        functions.logger.info(e);
      });

    // delete all news where campaign id is equival to campaignId
    await firestore
      .collection(DatabaseConstants.news)
      .where(CampaignFields.campaign_id, '==', campaignId)
      .get()
      .then(async (newSnapshot) => {
        for await (const doc of newSnapshot.docs) {
          await doc.ref.delete();
        }
      })
      .catch((e) => {
        functions.logger.info(e);
      });

    // delete all sessions and data inside sub collections where campaign id is equival to campaignId
    const campaignSessions = firestore
      .collection(DatabaseConstants.sessions)
      .where(CampaignFields.campaign_id, '==', campaignId);
    await campaignSessions
      .get()
      .then(async (sessions) => {
        for await (const doc of sessions.docs) {
          await doc.ref
            .listCollections()
            .then(async (list) => {
              console.log('subcollections length:' + list.length);
              for await (const collection of list) {
                await collection.get().then(async (col_docs) => {
                  for await (const col_doc of col_docs.docs) {
                    await col_doc.ref.delete();
                  }
                });
              }
            })
            .catch((e) => {
              functions.logger.info(e);
            });
          await doc.ref.delete();
        }
      })
      .catch((e) => {
        functions.logger.info(e);
      });
    // deleting images of campaign
    await bucket
      .deleteFiles({ prefix: `campaigns/campaign_${campaignId}/` })
      .then(() => {
        functions.logger.info('File deleted successfully');
      })
      .catch((e) => {
        functions.logger.error(e);
      });

    // set all donations from campaign to deleted
    const cDonations = firestore
      .collection(DatabaseConstants.donations)
      .where(DonationFields.campaign_id, '==', campaignId);

    await cDonations
      .get()
      .then(async (list) => {
        for await (const d of list.docs) {
          await d.ref.update({ campaign_deleted: true });
        }
      })
      .catch((e) => functions.logger.error(e));

    return 'Ok';
  });

exports.onUpdateCampaign = functions.firestore
  .document(`${DatabaseConstants.campaigns}/{campaignId}`)
  .onUpdate(async (snapshot, context) => {
    const campaignId: string = context.params.campaignId;
    const before: CampaignType = snapshot.before.data() as CampaignType;
    const after: CampaignType = snapshot.after.data() as CampaignType;

    if (
      before.title !== after.title ||
      before.image_url !== after.image_url ||
      before.short_video_url !== after.short_video_url ||
      before.long_video_url !== after.long_video_url ||
      before.dv_animation !== after.dv_animation
    ) {
      const updateValue = {
        campaign_name: after.title,
        campaign_img_url: after.image_url,
      };
      // update donations
      const toUpdateDonationsQuery = await firestore
        .collection(DatabaseConstants.donations)
        .where(CampaignFields.campaign_id, '==', campaignId)
        .get();

      for await (const doc of toUpdateDonationsQuery.docs) {
        await doc.ref.update(updateValue);
      }
      // update news
      const toUpdateNewsQuery = await firestore
        .collection(DatabaseConstants.news)
        .where(CampaignFields.campaign_id, '==', campaignId)
        .get();
      functions.logger.info(
        'news found to update:' + toUpdateNewsQuery.docs.length
      );

      for await (const doc of toUpdateNewsQuery.docs) {
        await doc.ref.update(updateValue);
      }

      // delete old short_video_url
      if (before.short_video_url && after.short_video_url === null) {
        console.log('Short video was deleted!');
        const path =
          'campaigns/campaign_' +
          campaignId +
          '/campaign_short_video_' +
          campaignId;
        await bucket.deleteFiles({
          prefix: path,
        });
      }

      // delete old long_video_url
      if (before.long_video_url && after.long_video_url === null) {
        console.log('Long video was deleted!');
        const path =
          'campaigns/campaign_' +
          campaignId +
          '/campaign_long_video_' +
          campaignId;
        await bucket.deleteFiles({
          prefix: path,
        });
      }

      // delete old dv_animation
      if (before.dv_animation && after.dv_animation === null) {
        console.log('Rive animation was deleted!');
        const path =
          'campaigns/campaign_' +
          campaignId +
          '/campaign_rive_anim_' +
          campaignId;
        await bucket.deleteFiles({
          prefix: path,
        });
      }

      if (
        before.image_url !== undefined &&
        before.image_url !== after.image_url &&
        before.image_url.endsWith(
          `${ImageResolutions.high}${ImageSuffix.dottJpg}`
        )
      ) {
        // delete old image_url
        functions.logger.info('Delete image of campaign');
        const image_path =
          'campaigns/campaign_' + campaignId + '/campaign_' + campaignId + '_0';
        await bucket.deleteFiles({
          prefix: image_path,
        });
      }
      // update sessions
      await firestore
        .collection(DatabaseConstants.sessions)
        .where(CampaignFields.campaign_id, '==', campaignId)
        .get()
        .then(async (sessions) => {
          functions.logger.info(
            'sessions found to update:' + sessions.docs.length
          );
          for await (const doc of sessions.docs) {
            await doc.ref.update(updateValue);
          }
        });
      // update subscribed campaigns
      const subscribedCampaignsUsersQuery = await firestore
        .collection(DatabaseConstants.campaigns_subscribed_users)
        .doc(campaignId)
        .collection(DatabaseConstants.users)
        .get();
      functions.logger.info(
        'subscribed users to update:' +
          subscribedCampaignsUsersQuery.docs.length
      );

      for await (const doc of subscribedCampaignsUsersQuery.docs) {
        await firestore
          .collection(DatabaseConstants.subscribed_campaigns)
          .doc(doc.data().id)
          .collection(DatabaseConstants.subscribed_campaigns)
          .doc(campaignId)
          .update(updateValue);
      }
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
  });
