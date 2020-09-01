import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { DatabaseConstants } from './database-constants';

exports.onCreateFriend = functions.firestore
  .document(
    `${DatabaseConstants.friends}/{userId}/${DatabaseConstants.users}/{friendId}`
  )
  .onCreate(async (snapshot, context) => {
    const userId = context.params.userId;
    const friendId = context.params.friendId;

    return admin
      .firestore()
      .collection(DatabaseConstants.friends)
      .doc(friendId)
      .collection(DatabaseConstants.users)
      .doc(userId)
      .set({ id: userId });
  });

exports.onDeleteFriend = functions.firestore
  .document(
    `${DatabaseConstants.friends}/{userId}/${DatabaseConstants.users}/{friendId}`
  )
  .onDelete(async (snapshot, context) => {
    const userId = context.params.userId;
    const friendId = context.params.friendId;

    return admin
      .firestore()
      .collection(DatabaseConstants.friends)
      .doc(friendId)
      .collection(DatabaseConstants.users)
      .doc(userId)
      .delete();
  });
