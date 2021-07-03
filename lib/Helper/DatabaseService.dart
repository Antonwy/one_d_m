import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:one_d_m/Helper/API/ApiError.dart';
import 'package:one_d_m/Helper/API/ApiResult.dart';
import 'package:one_d_m/Helper/API/ApiSuccess.dart';
import 'package:one_d_m/Helper/AdBalance.dart';
import 'package:one_d_m/Helper/DailyReport.dart';
import 'package:one_d_m/Helper/DonationInfo.dart';
import 'package:one_d_m/Helper/Feed.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/Organisation.dart';
import 'package:one_d_m/Helper/SearchResult.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/SessionMessage.dart';
import 'package:one_d_m/Helper/Statistics.dart';
import 'package:one_d_m/Helper/Suggestion.dart';
import 'package:one_d_m/Helper/UserCharge.dart';
// import 'package:stripe_payment/stripe_payment.dart';

import 'Campaign.dart';
import 'Donation.dart';
import 'GoalPageManager.dart';
import 'User.dart';

class DatabaseService {
  static const String CAMPAIGNS = "campaigns",
      USER = "user",
      CHARGESUSERS = "charges_users",
      USERS = "users",
      NEWS = "news",
      NEWSFEED = "news_feed",
      FEED = "feed",
      FRIENDS = "friends",
      SUBSCRIBEDCAMPAIGNS = "subscribed_campaigns",
      FOLLOWING = "following",
      FOLLOWED = "followed",
      CAMPAIGNNEWS = "campaign_news",
      DONATIONS = "donations",
      SORTEDDONATIONS = "sorted_donations",
      DONATIONFEED = "donation_feed",
      STATISTICS = "statistics",
      DONATIONINFO = "donation_info",
      CARDS = "cards",
      PRIVATEDATA = "private_data",
      ORGANISATIONS = "organizations",
      ADVERTISING_DATA = 'ad_data',
      ADVERTISING_BALANCE = 'balance',
      ADVERTISING_IMPRESSIONS = 'impressions',
      DATA = "data",
      SESSION_INVITES = "session_invites",
      SESSIONS = "sessions",
      SESSION_MEMBERS = "session_members",
      FINDFRIENDS = "httpFunctions-findFriends",
      CREATESESSION = "session-createSession",
      ACCEPTINVITE = "session-acceptInvite",
      DECLINEINVITE = "session-declineInvite",
      JOIN_CERTIFIED_SESSION = "session-joinCertifiedSession",
      LEAVE_CERTIFIED_SESSION = "session-leaveCertifiedSession",
      DEVICE_TOKEN = "device_token",
      FEEDBACK = "feedback",
      URL = "url",
      MESSAGES = "messages",
      GOALS = "goals",
      CHECKPOINTS = "checkpoints",
      SUGGESTIONS = "suggestions",
      DAILY_REPORTS = "daily_reports",
      SURVEYS = "surveys",
      RESULTS = "results",
      FEED_DATA = "feed_data";

  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static final FirebaseFunctions cloudFunctions = FirebaseFunctions.instance;
  static final CollectionReference userCollection = firestore.collection(USER);
  static final CollectionReference campaignsCollection =
      firestore.collection(CAMPAIGNS);
  static final CollectionReference newsCollection = firestore.collection(NEWS);
  static final CollectionReference subscribedCampaignsCollection =
      firestore.collection(SUBSCRIBEDCAMPAIGNS);
  static final CollectionReference feedCollection = firestore.collection(FEED);
  static final CollectionReference followingCollection =
      firestore.collection(FOLLOWING);
  static final CollectionReference followedCollection =
      firestore.collection(FOLLOWED);
  static final CollectionReference donationsCollection =
      firestore.collection(DONATIONS);
  static final CollectionReference donationFeedCollection =
      firestore.collection(DONATIONFEED);
  static final CollectionReference newsFeedCollection =
      firestore.collection(NEWSFEED);
  static final CollectionReference statisticsCollection =
      firestore.collection(STATISTICS);
  static final CollectionReference friendsCollection =
      firestore.collection(FRIENDS);
  static final CollectionReference userChargeCollection =
      firestore.collection(CHARGESUSERS);
  static final CollectionReference organisationsCollection =
      firestore.collection(ORGANISATIONS);
  static final CollectionReference sessionsCollection =
      firestore.collection(SESSIONS);
  static final CollectionReference dailyReportsCollection =
      firestore.collection(DAILY_REPORTS);
  static final CollectionReference goalsCollection =
      firestore.collection(GOALS);
  static final CollectionReference suggestionsCollection =
      firestore.collection(SUGGESTIONS);
  static final CollectionReference surveysCollection =
      firestore.collection(SURVEYS);

  static Future<bool> checkIfUserHasAlreadyAnAccount(String uid) async {
    DocumentSnapshot ds = await userCollection.doc(uid).get();
    return ds.exists && ds.data().containsKey(User.NAME);
  }

  static Future<bool> checkUsernameAvailable(String username) async {
    return (await userCollection.where(User.NAME, isEqualTo: username).get())
        .docs
        .isEmpty;
  }

  static Future<void> addUser(User user) async {
    await userCollection.doc(user.id).set(user.publicDataToMap());

    return userCollection
        .doc(user.id)
        .collection(PRIVATEDATA)
        .doc(DATA)
        .set({User.PHONE_NUMBER: user.phoneNumber}, SetOptions(merge: true));
  }

  static Future<void> updateUser(User user) async {
    await userCollection.doc(user.id).update({
      User.NAME: user.name,
      User.IMAGEURL: user.imgUrl,
      User.THUMBNAILURL: user.imgUrl == null ? null : user.thumbnailUrl,
    });
    return userCollection
        .doc(user.id)
        .collection(PRIVATEDATA)
        .doc(DATA)
        .update({User.PHONE_NUMBER: user.phoneNumber});
  }

  static Future<User> getUser(String uid) async {
    return User.fromSnapshot(await userCollection.doc(uid).get());
  }

  static Stream<User> getUserStream(String uid) {
    return userCollection
        .doc(uid)
        .snapshots()
        .map((ds) => User.fromSnapshot(ds));
  }

  static Stream<bool> isGhost(String uid) {
    return userCollection
        .doc(uid)
        .snapshots()
        .map((ds) => ds[User.GHOST] ?? false);
  }

  static Future<void> toggleGhost(String uid, bool to) {
    return userCollection.doc(uid).update({User.GHOST: to});
  }

  static Future<void> addInterstitialImpression(String uid) async {
    final userAdDocument = userCollection
        .doc(uid)
        .collection(ADVERTISING_DATA)
        .doc(ADVERTISING_IMPRESSIONS);

    return userAdDocument.set({
      User.INTERSTITIAL_IMPRESSIONS: FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  static Future<void> addNativeAdImpression(String uid) async {
    final userAdDocument = userCollection
        .doc(uid)
        .collection(ADVERTISING_DATA)
        .doc(ADVERTISING_IMPRESSIONS);

    return userAdDocument.set({
      User.NATIVE_AD_IMPRESSIONS: FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  static Stream<AdBalance> getAdBalance(String uid) {
    return userCollection
        .doc(uid)
        .collection(ADVERTISING_DATA)
        .doc(ADVERTISING_BALANCE)
        .snapshots()
        .map((snapshot) => AdBalance.fromSnapshot(snapshot));
  }

  static Future<AdBalance> getAdBalanceFuture(String uid) async {
    return AdBalance.fromSnapshot(await userCollection
        .doc(uid)
        .collection(ADVERTISING_DATA)
        .doc(ADVERTISING_BALANCE)
        .get());
  }

  static Future<void> incrementAdBalance(String uid, {int amount = 1}) {
    return userCollection
        .doc(uid)
        .collection(ADVERTISING_DATA)
        .doc(ADVERTISING_BALANCE)
        .update({AdBalance.DC_BALANCE: FieldValue.increment(amount)});
  }

  static Future<void> getGift(String uid, {int gift = 1}) async {
    await incrementAdBalance(uid, amount: gift);
    await userCollection
        .doc(uid)
        .collection(ADVERTISING_DATA)
        .doc(ADVERTISING_BALANCE)
        .update({AdBalance.GIFT: 0});
  }

  static Stream<String> getPhoneNumber(String uid) {
    return userCollection
        .doc(uid)
        .collection(PRIVATEDATA)
        .doc(DATA)
        .snapshots()
        .map((doc) => doc[User.PHONE_NUMBER]);
  }

  static Future<List<User>> getUsers([int limit = 20]) async {
    return User.listFromSnapshots((await userCollection
            .where(User.GHOST, isEqualTo: false)
            .limit(limit)
            .get())
        .docs);
  }

  static Stream<List<User>> streamUsers() {
    return FirebaseFirestore.instance
        .collection("user")
        .snapshots()
        .map((QuerySnapshot snapshot) {
      return snapshot.docs.map((e) {
        return User.fromSnapshot(e);
      }).toList();
    });
  }

  static Stream<List<User>> getUsersStream() {
    return userCollection
        .where(User.GHOST, isEqualTo: false)
        .limit(20)
        .snapshots()
        .map((qs) {
      return User.listFromSnapshots(qs.docs);
    });
  }

  static Stream<List<Campaign>> getCampaignFromQueryStream(String query) {
    return campaignsCollection
        .where(Campaign.NAME, isGreaterThanOrEqualTo: query)
        .snapshots()
        .map((qs) => Campaign.listFromSnapshot(qs.docs));
  }

  static Future<SearchResult> getSearchResultFromQuery(String query) async {
    List<Campaign> campaigns = await getCampaignFromQuery(query);
    List<User> users = await getUsersFromQuery(query);
    return SearchResult(campaigns: campaigns, users: users);
  }

  static Future<List<Campaign>> getCampaignFromQuery(String query,
      {limit: 5}) async {
    QuerySnapshot qs = await campaignsCollection
        .where(Campaign.NAME, isGreaterThanOrEqualTo: query)
        .limit(limit)
        .get();

    List<Campaign> campaigns =
        qs.docs.map((doc) => Campaign.fromSnapshot(doc)).toList();

    campaigns.removeWhere((Campaign c) => !c.name.contains(query));

    return campaigns;
  }

  static Future<List<User>> getUsersFromQuery(String query) async {
    QuerySnapshot nameSnapshot = await userCollection
        .where(User.GHOST, isEqualTo: false)
        .where(User.NAME, isGreaterThanOrEqualTo: query)
        .limit(5)
        .get();

    List<User> users = nameSnapshot.docs.map(User.fromSnapshot).toList();
    users.removeWhere((User c) => !c.name.contains(query));
    return users;
  }

  static Future<List<Organisation>> getOrganisationsFromQuery(
      String query) async {
    QuerySnapshot nameSnapshot = await organisationsCollection
        .where(Organisation.NAME, isGreaterThanOrEqualTo: query)
        .limit(5)
        .get();

    List<Organisation> org =
        nameSnapshot.docs.map((doc) => Organisation.fromMap(doc)).toList();

    org.removeWhere((Organisation c) => !c.name.contains(query));
    return org;
  }

  static Future<List<BaseSession>> getSessionsFromQuery(String query,
      {bool onlyCertified = false, String onlySessionsFrom}) async {
    Set<BaseSession> sessions = Set();

    List<Query> queries = [];

    queries.add(_filterQuery(
        queryString: query,
        onlyCertified: onlyCertified,
        onlySessionsFrom: onlySessionsFrom));

    if (query.isNotEmpty) {
      if (query[0].toUpperCase() == query[0]) {
        queries.add(_filterQuery(
            queryString: "${query[0].toLowerCase()}${query.substring(1)}",
            onlyCertified: onlyCertified,
            onlySessionsFrom: onlySessionsFrom));
      } else {
        queries.add(_filterQuery(
            queryString: "${query[0].toUpperCase()}${query.substring(1)}",
            onlyCertified: onlyCertified,
            onlySessionsFrom: onlySessionsFrom));
      }
    }

    for (Query query in queries) {
      QuerySnapshot snapshot = await query.get();
      sessions.addAll(snapshot.docs.map((doc) =>
          (doc.data()[BaseSession.IS_CERTIFIED] ?? true)
              ? CertifiedSession.fromDoc(doc)
              : Session.fromDoc(doc)));
    }

    sessions.removeWhere(
        (BaseSession s) => !s.name.toLowerCase().contains(query.toLowerCase()));
    return sessions.toList();
  }

  static Query _filterQuery(
      {String queryString, bool onlyCertified, String onlySessionsFrom}) {
    Query query = sessionsCollection;

    if (queryString.isNotEmpty)
      query = query.where(BaseSession.SESSION_NAME,
          isGreaterThanOrEqualTo: queryString);

    if (onlyCertified)
      query = query.where(BaseSession.IS_CERTIFIED, isEqualTo: true);
    if (onlySessionsFrom?.isNotEmpty ?? false)
      query = query.where(BaseSession.CREATOR_ID, isEqualTo: onlySessionsFrom);

    return query = query.limit(20);
  }

  static Future<void> createSubscription(Campaign campaign, String uid) async {
    await subscribedCampaignsCollection
        .doc(uid)
        .collection(CAMPAIGNS)
        .doc(campaign.id)
        .set(campaign.toShortMap());
  }

  static Future<void> deleteSubscription(Campaign campaign, String uid) async {
    // await campaignsCollection
    //     .doc(campaign.id)
    //     .update({Campaign.SUBSCRIBEDCOUNT: FieldValue.increment(-1)});
    // await userCollection.doc(uid).update({
    //   User.SUBSCRIBEDCAMPAIGNS: FieldValue.arrayRemove([campaign.id])
    // });
    await subscribedCampaignsCollection
        .doc(uid)
        .collection(CAMPAIGNS)
        .doc(campaign.id)
        .delete();
  }

  static Stream<List<Campaign>> getSubscribedCampaignsStream(String uid) {
    return subscribedCampaignsCollection
        .doc(uid)
        .collection(CAMPAIGNS)
        .snapshots()
        .map((qs) => Campaign.listFromShortSnapshot(qs.docs));
  }

  static Future<List<Campaign>> getSubscribedCampaigns(String uid) async {
    return (await subscribedCampaignsCollection
            .doc(uid)
            .collection(CAMPAIGNS)
            .get())
        .docs
        .map((doc) => Campaign.fromShortSnapshot(doc))
        .toList();
  }

  static Stream<bool> hasSubscribedCampaignStream(String uid, String cid) {
    return subscribedCampaignsCollection
        .doc(uid)
        .collection(CAMPAIGNS)
        .doc(cid)
        .snapshots()
        .map((doc) => doc.exists);
  }

  static Future<Campaign> getCampaign(String id) async {
    DocumentSnapshot ss = await campaignsCollection.doc(id).get();
    return Campaign.fromSnapshot(ss);
  }

  static Stream<Campaign> getCampaignStream(String id) {
    return campaignsCollection.doc(id).snapshots().map(Campaign.fromSnapshot);
  }

  static Stream<List<Campaign>> getCampaignsFromCategoryStream(int category) {
    return campaignsCollection
        .where(Campaign.CATEGORYID, isEqualTo: category)
        .snapshots()
        .map((qs) => Campaign.listFromSnapshot(qs.docs));
  }

  static Stream<List<Campaign>> getTopCampaignsStream() {
    return campaignsCollection.snapshots().map((qs) {
      return qs.docs.map((e) {
        return Campaign.fromSnapshot(e);
      }).toList();
    });
  }

  static Future<List<Campaign>> getTopCampaigns([int limit = 5]) async {
    return (await campaignsCollection.limit(limit).get())
        .docs
        .map(Campaign.fromSnapshot)
        .toList();
  }

  static Future<void> createCampaign(Campaign campaign) async {
    await campaignsCollection.doc(campaign.id).set(campaign.toMap());
  }

  static Future<void> deleteCampaign(Campaign campaign) async {
    await campaignsCollection.doc(campaign.id).delete();
  }

  static Future<List<News>> getNewsFromCampaign(Campaign campaign) async {
    return (await newsCollection
            .where(News.CAMPAIGNID, isEqualTo: campaign.id)
            .get())
        .docs
        .map((ds) => News.fromSnapshot(ds))
        .toList();
  }

  static Stream<List<News>> getNewsFromCampaignStream(String campaignId) {
    return newsCollection
        .where(News.CAMPAIGNID, isEqualTo: campaignId)
        .where(News.SESSION_ID, isEqualTo: "")
        .snapshots()
        .map((qs) => News.listFromSnapshot(qs.docs));
  }

  static Stream<List<News>> getNews() {
    return newsCollection
        .snapshots()
        .map((doc) => News.listFromSnapshot(doc.docs));
  }

  static Stream<List<News>> getSessionPosts() {
    return newsCollection
        .where('session_id', isNotEqualTo: '')
        .snapshots()
        .map((doc) => News.listFromSnapshot(doc.docs));
  }

  static Stream<List<News>> getAllPosts() {
    return newsCollection
        .orderBy(News.CREATEDAT, descending: true)
        .snapshots()
        .map((doc) => News.listFromSnapshot(doc.docs));
  }

  static Stream<List<News>> getMainFeedPosts() {
    return newsCollection
        .where(News.SHOW_IN_MAINFEED, isEqualTo: true)
        .orderBy(News.CREATEDAT, descending: true)
        .snapshots()
        .map((doc) => News.listFromSnapshot(doc.docs));
  }

  static Stream<List<News>> getPostBySessionId(String sessionId) {
    return newsCollection
        .where('session_id', isEqualTo: sessionId)
        .snapshots()
        .map((doc) => News.listFromSnapshot(doc.docs));
  }

  static Future<ApiResult> createNews(News news) async {
    try {
      await newsCollection.doc(news.id).set(news.toMap());
      return ApiSuccess();
    } on PlatformException catch (e) {
      return ApiError(e.message);
    }
  }

  static Future<void> createFollow(String meId, String toId) async {
    if (meId == toId) return;
    followingCollection
        .doc(meId)
        .collection(USERS)
        .doc(toId)
        .set({"id": toId, "createdAt": Timestamp.now()});
  }

  static Future<void> deleteFollow(String meId, String toId) async {
    if (meId == toId) return;
    followingCollection.doc(meId).collection(USERS).doc(toId).delete();
  }

  static Stream<bool> getFollowStream(String meId, String toId) {
    return followingCollection
        .doc(meId)
        .collection(USERS)
        .doc(toId)
        .snapshots()
        .map((ss) => ss.exists);
  }

  static Stream<List<String>> getFollowingUsersStream(String uid, {int limit}) {
    return limit != null
        ? followingCollection
            .doc(uid)
            .collection(USERS)
            .limit(limit)
            .snapshots()
            .map((qs) => qs.docs.map((ds) => ds.id).toList())
        : followingCollection
            .doc(uid)
            .collection(USERS)
            .snapshots()
            .map((qs) => qs.docs.map((ds) => ds.id).toList());
  }

  static Stream<List<String>> getFollowedUsersStream(String uid) {
    return followedCollection
        .doc(uid)
        .collection(USERS)
        .snapshots()
        .map((qs) => qs.docs.map((ds) => ds.id).toList());
  }

  static Stream<QuerySnapshot> getFollowedUsersStreamRaw(String uid) {
    return followedCollection.doc(uid).collection(USERS).snapshots();
  }

  static Future<List<Campaign>> getCampaignListFromIds(List<String> ids) async {
    List<Campaign> campaigns = [];

    for (String id in ids) {
      campaigns
          .add(Campaign.fromSnapshot(await campaignsCollection.doc(id).get()));
    }

    return campaigns;
  }

  static Future<List<Campaign>> getMyCampaigns(String uid) async {
    return (await campaignsCollection
            .where(Campaign.AUTHORID, isEqualTo: uid)
            .get())
        .docs
        .map(Campaign.fromSnapshot)
        .toList();
  }

  static Future<void> donate(Donation donation) async {
    await donationsCollection.add(donation.toMap());
  }

  static Stream<List<Donation>> getDonationFromCampaignStream(
      String campaignId) {
    return donationsCollection
        .where(Donation.CAMPAIGNID, isEqualTo: campaignId)
        // .orderBy(Donation.CREATEDAT, descending: true)
        .limit(6)
        .snapshots()
        .map((qs) => Donation.listFromSnapshots(qs.docs));
  }

  static Stream<List<Donation>> getDonationFeedStream(String uid) {
    return donationFeedCollection
        .doc(uid)
        .collection(DONATIONS)
        // .orderBy(Donation.CREATEDAT, descending: true)
        .limit(20)
        .snapshots()
        .map((qs) => Donation.listFromSnapshots(qs.docs));
  }

  static Stream<DonationInfo> getDonationInfo() {
    return statisticsCollection
        .doc(DONATIONINFO)
        .snapshots()
        .map((ds) => DonationInfo.fromSnapshot(ds));
  }

  static Stream<List<Donation>> getDonationsFromUser(String uid) {
    return donationsCollection
        .where(Donation.USERID, isEqualTo: uid)
        .where(Donation.ISANONYM, isEqualTo: false)
        // .orderBy(Donation.CREATEDAT, descending: true)
        .snapshots()
        .map((qs) => Donation.listFromSnapshots(qs.docs));
  }

  static Stream<List<Donation>> getDonationsFromUserLimit(String uid) {
    return donationsCollection
        .where(Donation.USERID, isEqualTo: uid)
        .where(Donation.ISANONYM, isEqualTo: false)
        // .orderBy(Donation.CREATEDAT, descending: true)
        .limit(4)
        .snapshots()
        .map((qs) => Donation.listFromSnapshots(qs.docs));
  }

  static Stream<List<Donation>> getTodaysDonationsFromUser(String uid) {
    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);

    return donationsCollection
        .where(Donation.USERID, isEqualTo: uid)
        .where(Donation.CREATEDAT,
            isGreaterThanOrEqualTo: Timestamp.fromDate(date))
        .snapshots()
        .map((qs) => Donation.listFromSnapshots(qs.docs));
  }

  static Stream<List<Donation>> getLatestDonations(
      {int limit = 3, bool isDescending = true}) {
    return donationsCollection
        .where(Donation.ISANONYM, isEqualTo: false)
        .orderBy(Donation.CREATEDAT, descending: isDescending)
        .limit(limit)
        .snapshots()
        .map((qs) => Donation.listFromSnapshots(qs.docs));
  }

  static Future<UserCharge> getUserCharge(String uid) async {
    return UserCharge.fromMap(await userChargeCollection.doc(uid).get());
  }

  static Stream<Statistics> getStatistics() {
    return statisticsCollection.snapshots().map(Statistics.fromQuerySnapshot);
  }

  static Future<List<User>> getUsersFromContacts(List<Contact> contacts) async {
    List<User> userList = [];

    Set<String> numbers = HashSet();

    for (Contact c in contacts) {
      List<String> contactNumbers = c.phones.map((item) => item.value).toList();
      numbers.addAll(contactNumbers);
      List<String> tempContactNumbers = List.of(contactNumbers);

      for (String number in tempContactNumbers) {
        if (number.startsWith("+49")) {
          numbers.add(number.replaceFirst("+49", "0"));
        } else if (number.startsWith("0")) {
          numbers.add(number.replaceFirst("0", "+49"));
        } else {
          numbers.remove(number);
        }
      }
    }

    for (var i = 0; i < numbers.length; i += 10) {
      List<String> queryNumbers = numbers
          .toList()
          .getRange(i, (i + 10) > numbers.length ? numbers.length : i + 10)
          .toList();
      QuerySnapshot qs = await firestore
          .collectionGroup(PRIVATEDATA)
          .where(User.PHONE_NUMBER, whereIn: queryNumbers)
          .get();
      if (qs.docs.isNotEmpty) {
        for (DocumentSnapshot doc in qs.docs) {
          userList
              .add(User.fromSnapshot(await doc.reference.parent.doc().get()));
        }
      }
    }

    return userList;
  }

  // static Future<void> addCard({PaymentMethod card, String uid}) {
  //   return userCollection
  //       .doc(uid)
  //       .collection(CARDS)
  //       .doc(card.id)
  //       .set(card.toJson());
  // }

  // static Future<void> deleteCard({PaymentMethod card, String uid}) {
  //   return userCollection.doc(uid).collection(CARDS).doc(card.id).delete();
  // }

  // static Stream<List<PaymentMethod>> getCards(String uid) {
  //   return userCollection.doc(uid).collection(CARDS).snapshots().map((qs) =>
  //       qs.docs.map((doc) => PaymentMethod.fromJson(doc.data())).toList());
  // }

  static Stream<bool> hasPaymentMethod(String uid) {
    return userCollection
        .doc(uid)
        .collection(CARDS)
        .snapshots()
        .map((qs) => qs.docs.isNotEmpty);
  }

  static Future<List<String>> getFriends(String uid) async {
    return (await friendsCollection.doc(uid).collection(USERS).get())
        .docs
        .map((doc) => doc.id)
        .toList();
  }

  static Stream<List<String>> getFriendsStream(String uid) {
    return friendsCollection
        .doc(uid)
        .collection(USERS)
        .snapshots()
        .map((qs) => qs.docs.map((doc) => doc.id).toList());
  }

  static Future<void> saveDeviceToken(String uid, String token) async {
    if (!(await userCollection.doc(uid).get()).exists) return;
    return (await userCollection
        .doc(uid)
        .collection(PRIVATEDATA)
        .doc(DATA)
        .set({User.DEVICETOKEN: token}, SetOptions(merge: true)));
  }

  static Future<void> deleteDeviceToken(String uid) async {
    return (await userCollection
        .doc(uid)
        .collection(PRIVATEDATA)
        .doc(DATA)
        .set({User.DEVICETOKEN: null}, SetOptions(merge: true)));
  }

  static Future<Organisation> getOrganisation(String oid) async {
    return Organisation.fromMap(await organisationsCollection.doc(oid).get());
  }

  static Future<Organisation> getOrganisationOfCampaign(String cid) async {
    Campaign campaign =
        Campaign.fromSnapshot(await campaignsCollection.doc(cid).get());
    return Organisation.fromMap(
        await organisationsCollection.doc(campaign.authorId).get());
  }

  static Stream<List<Campaign>> getCampaignsOfOrganisation(String oid) {
    return campaignsCollection
        .where(Campaign.AUTHORID, isEqualTo: oid)
        .snapshots()
        .map((qs) => Campaign.listFromSnapshot(qs.docs));
  }

  static Future<void> createSession(UploadableSession session) {
    return sessionsCollection
        .doc(session.id)
        .set(session.toMap(), SetOptions(merge: true));
  }

  static Future<void> deleteSession(BaseSession session) {
    return sessionsCollection.doc(session.id).delete();
  }

  static Future<void> updateSession(UploadableSession session) {
    return sessionsCollection.doc(session.id).update(session.toUpdateMap());
  }

  static Stream<List<BaseSession>> getSessionsFromUser(String uid) {
    return userCollection
        .doc(uid)
        .collection(SESSIONS)
        .where(BaseSession.END_DATE, isGreaterThanOrEqualTo: DateTime.now())
        // .orderBy(BaseSession.END_DATE, descending: true)
        .snapshots()
        .map((BaseSession.fromQuerySnapshot));
  }

  static Stream<List<BaseSession>> getCertifiedSessionsFromUser(String uid) {
    return userCollection
        .doc(uid)
        .collection(SESSIONS)
        .where(BaseSession.END_DATE, isNull: true)
        .snapshots()
        .map((BaseSession.fromQuerySnapshot));
  }

  static Future<List<String>> getCertifiedSessionsFromUserFuture(
      String uid) async {
    if (uid == null) return [];
    return (await userCollection.doc(uid).collection(SESSIONS).get())
        .docs
        .map((doc) => doc.id)
        .toList();
  }

  static Stream<List<CertifiedSession>> getCertifiedSessions() {
    return sessionsCollection
        .where(BaseSession.IS_CERTIFIED, isEqualTo: true)
        .snapshots()
        .map((qs) {
      return qs.docs.map((e) {
        return CertifiedSession.fromDoc(e);
      }).toList();
    });
  }

  static Stream<List<CertifiedSession>> getCertifiedSessionsFromCampaign(
      String campaignId) {
    return sessionsCollection
        .where(BaseSession.IS_CERTIFIED, isEqualTo: true)
        .where('campaign_id', isEqualTo: campaignId)
        .snapshots()
        .map((qs) {
      return qs.docs.map((e) {
        return CertifiedSession.fromDoc(e);
      }).toList();
    });
  }

  static Stream<BaseSession> getSession(String sid) {
    return sessionsCollection.doc(sid).snapshots().map((doc) =>
        (doc.data()[BaseSession.IS_CERTIFIED] ?? true)
            ? CertifiedSession.fromDoc(doc)
            : Session.fromDoc(doc));
  }

  static Stream<List<BaseSession>> getSessions([int limit = 20]) {
    return sessionsCollection
        .orderBy(BaseSession.IS_CERTIFIED, descending: true)
        .orderBy(BaseSession.SORT_IMPORTANCE, descending: true)
        .limit(limit)
        .snapshots()
        .map((qs) => BaseSession.fromQuerySnapshot(qs));
  }

  static Future<List<BaseSession>> getSessionsFuture([int limit = 20]) async {
    return BaseSession.fromQuerySnapshot(await sessionsCollection
        .orderBy(BaseSession.IS_CERTIFIED, descending: true)
        .orderBy(BaseSession.SORT_IMPORTANCE, descending: true)
        .limit(limit)
        .get());
  }

  static Stream<bool> userIsInSession(String uid, String sid) {
    return sessionsCollection
        .doc(sid)
        .collection(SESSION_MEMBERS)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists);
  }

  static Stream<bool> userExist(String uid) {
    return userCollection.doc(uid).snapshots().map((doc) => doc.exists);
  }

  static Future<bool> userIsFollowSession(String uid, String sid) {
    return sessionsCollection
        .doc(sid)
        .collection(SESSION_MEMBERS)
        .doc(uid)
        .get()
        .then((value) => value.exists);
  }

  static Future<List<BaseSession>> getUserFollowingSessions(String uid) {
    List<BaseSession> sessions;
    getCertifiedSessions().listen((session) async {
      session.forEach((e) {
        sessionsCollection
            .doc(e.id)
            .collection(SESSION_MEMBERS)
            .doc(uid)
            .get()
            .then((value) {
          if (value.exists) {
            sessions.add(e);
          }
        });
      });
      return sessions;
    });
  }

  static Future<BaseSession> getSessionFuture(String sid) async {
    DocumentSnapshot doc = await sessionsCollection.doc(sid).get();
    print(doc.data()[BaseSession.IS_CERTIFIED]);
    return (doc.data()[BaseSession.IS_CERTIFIED] ?? true)
        ? CertifiedSession.fromDoc(doc)
        : Session.fromDoc(doc);
  }

  static Stream<List<SessionMember>> getSessionMembers(String sid,
      [int limit = 50]) {
    return sessionsCollection
        .doc(sid)
        .collection(SESSION_MEMBERS)
        .limit(limit)
        .orderBy(SessionMember.DONATION_AMOUNT, descending: true)
        .snapshots()
        .map(SessionMember.fromQuerySnapshot);
  }

  static Stream<List<SessionMember>> getInvitedSessionMembers(String sid) {
    return sessionsCollection
        .doc(sid)
        .collection(SESSION_INVITES)
        .snapshots()
        .map(SessionMember.fromQuerySnapshot);
  }

  static Stream<int> getDonatedAmountToSession({String sid, String uid}) {
    return sessionsCollection
        .doc(sid)
        .collection(SESSION_MEMBERS)
        .doc(uid)
        .snapshots()
        .map((doc) => doc[SessionMember.DONATION_AMOUNT]);
  }

  static Stream<List<Donation>> getDonationsFromSession(String sid,
      [int limit = 100]) {
    return donationsCollection
        .where(Donation.SESSION_ID, isEqualTo: sid)
        .limit(limit)
        .where(Donation.ISANONYM, isEqualTo: false)
        .snapshots()
        .map((qs) => Donation.listFromSnapshots(qs.docs));
  }

  static Future<void> sendMessageToSession(SessionMessage msg) {
    return sessionsCollection
        .doc(msg.toSid)
        .collection(MESSAGES)
        .add(msg.toMap());
  }

  static Stream<List<SessionMessage>> getSessionMessages(String sid) {
    return sessionsCollection
        .doc(sid)
        .collection(MESSAGES)
        // .orderBy(SessionMessage.CREATED_AT, descending: true)
        .snapshots()
        .map(SessionMessage.fromQuerySnapshot);
  }

  static Future<HttpsCallableResult> callFindFriends(List<String> numbers) {
    return cloudFunctions.httpsCallable(FINDFRIENDS).call(numbers);
  }

  static Stream<List<SessionInvite>> getSessionInvites(String uid) {
    return userCollection
        .doc(uid)
        .collection(SESSION_INVITES)
        .snapshots()
        .map((SessionInvite.fromQuerySnapshot));
  }

  static Future<HttpsCallableResult> acceptSessionInvite(SessionInvite invite) {
    return cloudFunctions.httpsCallable(ACCEPTINVITE).call(invite.toMap());
  }

  static Future<HttpsCallableResult> declineSessionInvite(
      SessionInvite invite) {
    return cloudFunctions.httpsCallable(DECLINEINVITE).call(invite.toMap());
  }

  static Future<HttpsCallableResult> joinCertifiedSession(String sid) {
    return cloudFunctions
        .httpsCallable(JOIN_CERTIFIED_SESSION)
        .call({"session_id": sid});
  }

  static Future<HttpsCallableResult> leaveCertifiedSession(String sid) {
    return cloudFunctions
        .httpsCallable(LEAVE_CERTIFIED_SESSION)
        .call({"session_id": sid});
  }

  static Stream<bool> hasPushNotificationsTurnedOnStream(String uid) {
    return userCollection
        .doc(uid)
        .collection(PRIVATEDATA)
        .doc(DATA)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return false;
      if (doc.data().containsKey(DEVICE_TOKEN)) {
        String token = doc.data()[DEVICE_TOKEN];

        if (token == null || token.isEmpty) return false;
        return true;
      }
    });
  }

  static Future<bool> hasPushNotificationsTurnedOn(String uid) async {
    try {
      DocumentSnapshot doc =
          await userCollection.doc(uid).collection(PRIVATEDATA).doc(DATA).get();
      if (!doc.exists) return false;
      if (doc.data() == null) return false;
      if (doc.data().containsKey(DEVICE_TOKEN)) {
        String token = doc.data()[DEVICE_TOKEN];
        if (token == null || token.isEmpty) return false;
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<String> getFeedbackUrl() async {
    return (await statisticsCollection.doc(FEEDBACK).get()).data()[URL];
  }

  static Future<DailyReport> getDailyReportFuture([DateTime date]) async {
    String dateString = DateFormat("dd.MM.yyyy").format(date ?? DateTime.now());
    return DailyReport.fromDoc(
        await dailyReportsCollection.doc(dateString).get());
  }

  static Stream<DailyReport> getDailyReport([DateTime date]) {
    String dateString = DateFormat("dd.MM.yyyy").format(date ?? DateTime.now());
    return dailyReportsCollection
        .doc(dateString)
        .snapshots()
        .map((doc) => DailyReport.fromDoc(doc));
  }

  static Stream<List<DailyReport>> getAllDailyReports() {
    return dailyReportsCollection
        .orderBy("date", descending: true)
        .snapshots()
        .map(DailyReport.fromQuerySnapshot);
  }

  static Stream<List<Goal>> getGoals() {
    return goalsCollection.snapshots().map(Goal.fromQuerySnapshot);
  }

  static Stream<List<GoalCheckpoint>> getCheckpointsOfGoal(String gid) {
    return goalsCollection
        .doc(gid)
        .collection(CHECKPOINTS)
        .orderBy(GoalCheckpoint.VALUE, descending: false)
        .snapshots()
        .map(GoalCheckpoint.fromQuerySnapshot);
  }

  static Future<List<Suggestion>> getSuggestions() async {
    return (await suggestionsCollection.get())
        .docs
        .map((doc) => Suggestion.fromDoc(doc))
        .toList();
  }

  static Stream<FeedDoc> getUserFeedDoc(String uid) {
    return feedCollection
        .doc(uid)
        .snapshots()
        .map((doc) => FeedDoc.fromDoc(doc));
  }

  static Stream<List<FeedObject>> getFeed(String uid) {
    return feedCollection
        .doc(uid)
        .collection(FEED_DATA)
        .orderBy(FeedObject.CREATED_AT, descending: true)
        .snapshots()
        .map(FeedObject.fromQuerySnapshot);
  }

  static Future<void> unseeFeed(String uid) {
    return feedCollection.doc(uid).set({FeedDoc.UNSEEN_OBJECTS: []});
  }

  static Future<Survey> getSurveyDeleteFromFeedIfNotExists(
      String sid, String uid) async {
    DocumentSnapshot snap = await surveysCollection.doc(sid).get();
    if (!snap.exists) {
      print("DELETING $sid from $uid");
      await feedCollection.doc(uid).collection(FEED_DATA).doc(sid).delete();
      return null;
    }
    return Survey.fromDoc(snap);
  }

  static Future<void> sendSurveyResults(Survey survey, {String uid}) {
    return surveysCollection
        .doc(survey.id)
        .collection(RESULTS)
        .doc(uid)
        .set(survey.buildResult());
  }

  static Future<bool> hasContributedToSurvey({String uid, String sid}) async {
    return (await surveysCollection.doc(sid).collection(RESULTS).doc(uid).get())
            ?.exists ??
        false;
  }
}
