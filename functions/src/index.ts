import * as admin from 'firebase-admin';

admin.initializeApp({ storageBucket: 'one-dollar-movement.appspot.com' });

exports.scheduled = require('./scheduled-functions');
exports.donations = require('./donation-functions');
exports.campaigns = require('./campaign-functions');
exports.followers = require('./follower-functions');
exports.news = require('./news-functions');
exports.user = require('./user-functions');
exports.storage = require('./storage-functions');
exports.httpFunctions = require('./http-functions');
exports.friends = require('./friends-functions');
exports.ads = require('./ad-functions');
exports.session = require('./session-functions');
exports.organization = require('./organization-functions');