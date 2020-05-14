import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

exports.onCreateFriend = functions.firestore
  .document('friends/{userId}/users/{friendId}')
  .onCreate(async (snapshot, context) => {
    const userId = context.params.userId;
    const friendId = context.params.friendId;

    return admin
      .firestore()
      .collection('friends')
      .doc(friendId)
      .collection('users')
      .doc(userId)
      .set({ id: userId });
  });

exports.onDeleteFriend = functions.firestore
  .document('friends/{userId}/users/{friendId}')
  .onDelete(async (snapshot, context) => {
    const userId = context.params.userId;
    const friendId = context.params.friendId;

    return admin
      .firestore()
      .collection('friends')
      .doc(friendId)
      .collection('users')
      .doc(userId)
      .delete();
  });
