import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { DatabaseConstants, SurveyTypes } from './database-constants';
import { FeedType, SurveyType } from './types';

const firestore = admin.firestore();
// const increment = admin.firestore.FieldValue.increment;

export const onCreateSurvey = functions.firestore
  .document(`${DatabaseConstants.surveys}/{surveyId}`)
  .onCreate(async (snapshot, context) => {
    const survey = snapshot.data() as SurveyType;
    const surveyId = snapshot.id;

    console.log(`Starting onUpdateSurvey for ${survey} with id ${surveyId}`);

    const users = await firestore.collection(DatabaseConstants.user).get();

    console.log(`Found ${users.docs.length} users`);

    for await (const user of users.docs) {
      console.log(`Adding Survey to ${user.data().name} with id: ${user.id}`);

      const userFeedRef = firestore
        .collection(DatabaseConstants.feed)
        .doc(user.id);

      await userFeedRef
        .collection(DatabaseConstants.feed_data)
        .doc(surveyId)
        .set(
          {
            id: surveyId,
            created_at: admin.firestore.Timestamp.now(),
            feed_type: 'survey',
          } as FeedType,
          { merge: true }
        );

      console.log(
        `Added survey to ${user.data().name}'s feed. Starting to add unseen.`
      );

      await userFeedRef.set(
        { unseen_objects: admin.firestore.FieldValue.arrayUnion(surveyId) },
        { merge: true }
      );

      console.log(`Finished ${user.data().name}'s feed.`);
    }

    console.log(
      `Finished rolling out new survey for ${users.docs.length} users.`
    );
  });

export const onCreateSurveyResult = functions.firestore
  .document(
    `${DatabaseConstants.surveys}/{surveyId}/${DatabaseConstants.results}/{userId}`
  )
  .onCreate(async (snapshot, context) => {
    const { surveyId } = context.params;
    const result = snapshot.data().result;
    const survey_type = snapshot.data().survey_type;

    console.log(Object.entries(result));

    console.log(`Starting to evaluate survey results... ${result}`);
    let updateMap: { [k: string]: number } = {};

    const survey = (
      await firestore.collection(DatabaseConstants.surveys).doc(surveyId).get()
    ).data() as SurveyType;

    if (survey_type === SurveyTypes.multiple_choice) {
      console.log(surveyId);

      console.log('*** SURVEY ***');
      console.log(survey.evaluation);

      for (const [key, value] of Object.entries(result)) {
        updateMap[`${DatabaseConstants.evaluation}.${key}`] =
          ((survey.evaluation ?? {})[key] ?? 0) + (value ? 1 : 0);
      }

      console.log(updateMap);
    } else if (survey_type === SurveyTypes.single_answer) {
      console.log(surveyId);

      console.log('*** SURVEY ***');
      console.log(survey.evaluation);

      const singleAnswerResult =
        snapshot.data().result?.trim()?.toLowerCase() ?? 'no-valid-data';

      console.log(`Survey result is: ${singleAnswerResult}`);

      if (singleAnswerResult === 'true' || singleAnswerResult === 'false') {
        updateMap[`${DatabaseConstants.evaluation}.${singleAnswerResult}`] =
          ((survey.evaluation ?? {})[`${singleAnswerResult}`] ?? 0) + 1;
      }

      console.log(updateMap);
    }

    updateMap[DatabaseConstants.result_count] = (survey.result_count ?? 0) + 1;

    await firestore
      .collection(DatabaseConstants.surveys)
      .doc(surveyId)
      .update(updateMap);
  });
