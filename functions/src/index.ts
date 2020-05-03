import * as admin from 'firebase-admin';

admin.initializeApp();

exports.donations = require('./donation-functions');
exports.campaigns = require('./campaign-functions');
exports.followers = require('./follower-functions');
exports.news = require('./news-functions');

