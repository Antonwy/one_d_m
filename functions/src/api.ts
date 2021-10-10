import axios from 'axios';
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { DonationType } from './types';

const apiUrl = 'https://one-dollar-movement.appspot.com';

export const updateAccount = async (toUpdate: {}, token: string) => {
  console.log("Sending 'PUT' request to: " + apiUrl + '/account');
  console.log('Using auth token: ' + token);
  const res = await axios.put(apiUrl + '/account', toUpdate, {
    headers: { 'Content-Type': 'application/json', authtoken: token },
  });

  console.log('Api Res: ' + res.data);
};

export const updateDatabase = async (
  route: string,
  toUpdate: {},
  token: string
) => {
  console.log("Sending 'PUT' request to: " + apiUrl + '/' + route);
  console.log('Using auth token: ' + token);
  const res = await axios.put(apiUrl + '/' + route, toUpdate, {
    headers: { 'Content-Type': 'application/json', authtoken: token },
  });

  console.log('Api Res: ' + res.data);
};

export const deleteUser = async (uid: string) => {
  const token = await getToken(uid);

  console.log("Sending 'DELETE' request to: " + apiUrl + '/users/' + uid);
  console.log('Using auth token: ' + token);
  const res = await axios.delete(apiUrl + '/users/' + uid, {
    headers: { 'Content-Type': 'application/json', authtoken: token },
  });

  console.log('Api Res: ' + res.data);
};

export const getToken = async (uid: string) => {
  console.log('Creating custom token....');
  const customToken = await admin.auth().createCustomToken(uid);
  console.log('Custom Token: ' + customToken);

  const res = await axios.post(
    'https://identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=' +
      functions.config().vars.api_key,
    {
      token: customToken,
      returnSecureToken: true,
    }
  );
  console.log('Response: ' + res.data.idToken);

  return res.data.idToken;
};

export const createDonation = async (donation: DonationType, uid: string) => {
  if (!uid) return;
  const token = await getToken(uid);

  console.log('Starting to post donation ' + donation);
  const res = await axios.post(
    `${apiUrl}/donations`,
    { ...donation, alread_inserted: true },
    {
      headers: { 'Content-Type': 'application/json', authtoken: token },
    }
  );

  console.log('Response: ' + res.data);
};

export const addDv = async (amount: number, uid: string) => {
  if (!uid) return;
  const token = await getToken(uid);

  console.log('Starting to add dvs ' + amount + ' to ' + uid);
  try {
    const res = await axios.put(
      `${apiUrl}/account/addDv/${amount}`,
      {},
      {
        headers: { 'Content-Type': 'application/json', authtoken: token },
      }
    );
    console.log('Response: ' + res.data);
  } catch (error) {
    console.log('FAILED ADD DV');
    console.log(error);
  }
};
