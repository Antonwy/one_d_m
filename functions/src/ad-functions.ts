// import * as functions from 'firebase-functions';
// import { DatabaseConstants, UserAdFields } from './database-constants';
// import * as admin from 'firebase-admin';
// import FieldValue = admin.firestore.FieldValue;

// const firestore = admin.firestore();

// // exports.onAdDocChanged = functions.firestore
// //   .document(
// //     `${DatabaseConstants.user}/{userId}/${DatabaseConstants.advertising_data}/${DatabaseConstants.ad_impressions}`
// //   )
// //   .onWrite(async (snapshot, context) => {
// //     const userId: string = context.params.userId;

// //     const nativeAdImpressions: number = (snapshot.after.data() as any)[
// //       UserAdFields.native_ad_impressions
// //     ];
// //     const interstitialImpressions: number = (snapshot.after.data() as any)[
// //       UserAdFields.interstitial_impressions
// //     ];

// //     const cpmRates = (
// //       await firestore
// //         .collection(DatabaseConstants.statistics)
// //         .doc(DatabaseConstants.cpm_rates)
// //         .get()
// //     ).data();

// //     const nativeAdCPM: number = cpmRates?.native_ad ?? 1.4;
// //     const interstitialCPM: number = cpmRates?.interstitial ?? 2.1;

// //     const moneyGeneratedSinceLastDC: number =
// //       (nativeAdImpressions || 0) * (nativeAdCPM / 1000) +
// //       (interstitialImpressions || 0) * (interstitialCPM / 1000);

// //     if (moneyGeneratedSinceLastDC > 0.1) {
// //       await firestore
// //         .collection(DatabaseConstants.user)
// //         .doc(userId)
// //         .collection(DatabaseConstants.advertising_data)
// //         .doc(DatabaseConstants.ad_balance)
// //         .set(
// //           {
// //             dc_balance: FieldValue.increment(1),
// //             activity_score: 0,
// //           },
// //           { merge: true }
// //         );

// //       await firestore
// //         .collection(DatabaseConstants.user)
// //         .doc(userId)
// //         .collection(DatabaseConstants.advertising_data)
// //         .doc(DatabaseConstants.ad_impressions)
// //         .set(
// //           {
// //             native_ad_impressions: 0,
// //             interstitial_impressions: 0,
// //           },
// //           { merge: true }
// //         );
// //     } else {
// //       const activityScore: number = moneyGeneratedSinceLastDC / 0.1;

// //       await firestore
// //         .collection(DatabaseConstants.user)
// //         .doc(userId)
// //         .collection(DatabaseConstants.advertising_data)
// //         .doc(DatabaseConstants.ad_balance)
// //         .set(
// //           {
// //             activity_score: activityScore,
// //           },
// //           { merge: true }
// //         );
// //     }
// //   });
