import { firestore } from 'firebase-admin';
const firebase_tools = require('firebase-tools');

export const recursiveDelete = async (query: firestore.CollectionReference) => {
  const path = query.path;

  await firebase_tools.firestore.delete(path, {
    project: process.env.GCLOUD_PROJECT,
    recursive: true,
    yes: true,
  });

  return {
    path: path,
  };
};
