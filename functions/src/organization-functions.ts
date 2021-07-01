import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { DatabaseConstants, CampaignFields } from './database-constants';

exports.onOrganizationDeleted = functions.firestore
  .document(DatabaseConstants.organisations + '/{organizationId}')
  .onDelete(async (snapshot, context) => {
    const organizationId = context.params.organizationId;
    await admin
      .firestore()
      .collection(DatabaseConstants.campaigns)
      .where(CampaignFields.author_id, '==', organizationId)
      .get()
      .then(async (campaigns) => {
        functions.logger.info(
          'total campaigns deleted: ' + campaigns.docs.length
        );
        for await (const campaign of campaigns.docs) {
          await campaign.ref.delete();
        }
      })
      .catch((e) => {
        functions.logger.info(e);
      });

    await admin.auth().deleteUser(organizationId);
  });
