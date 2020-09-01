import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/services.dart';
import 'package:one_d_m/Helper/API/ApiError.dart';
import 'package:one_d_m/Helper/API/ApiResult.dart';
import 'package:one_d_m/Helper/API/ApiSuccess.dart';
import 'package:one_d_m/Helper/DonationInfo.dart';
import 'package:one_d_m/Helper/DonationsGroup.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/Ranking.dart';
import 'package:one_d_m/Helper/SearchResult.dart';
import 'package:one_d_m/Helper/Statistics.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'Campaign.dart';
import 'Donation.dart';
import 'User.dart';

class DatabaseService {
  static const String CAMPAIGNS = "campaigns",
      USER = "user",
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
      DATA = "data";

  static final Firestore firestore = Firestore.instance;
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

  static Future<bool> checkIfUserHasAlreadyAnAccount(String uid) async {
    DocumentSnapshot ds = await userCollection.document(uid).get();
    return ds.exists && ds.data.containsKey(User.NAME);
  }

  static Future<bool> checkUsernameAvailable(String username) async {
    return (await userCollection
            .where(User.NAME, isEqualTo: username)
            .getDocuments())
        .documents
        .isEmpty;
  }

  static Future<void> addUser(User user) async {
    await userCollection.document(user.id).setData(user.publicDataToMap());

    return userCollection
        .document(user.id)
        .collection(PRIVATEDATA)
        .document(DATA)
        .setData(user.privateDataToMap(), merge: true);
  }

  static Future<void> updateUser(User user) async {
    await userCollection.document(user.id).updateData({
      User.NAME: user.name,
      User.IMAGEURL: user.imgUrl,
      User.THUMBNAILURL: user.imgUrl == null ? null : user.thumbnailUrl,
    });
    return userCollection
        .document(user.id)
        .collection(PRIVATEDATA)
        .document(DATA)
        .updateData({User.PHONE_NUMBER: user.phoneNumber});
  }

  static Future<User> getUser(String uid) async {
    return User.fromSnapshot(await userCollection.document(uid).get());
  }

  static Stream<User> getUserStream(String uid) {
    return userCollection
        .document(uid)
        .snapshots()
        .map((ds) => User.fromSnapshot(ds));
  }

  static Stream<bool> isGhost(String uid) {
    return userCollection
        .document(uid)
        .snapshots()
        .map((ds) => ds[User.GHOST] ?? false);
  }

  static Future<void> toggleGhost(String uid, bool to) {
    return userCollection.document(uid).updateData({User.GHOST: to});
  }

  static Stream<String> getPhoneNumber(String uid) {
    return userCollection
        .document(uid)
        .collection(PRIVATEDATA)
        .document(DATA)
        .snapshots()
        .map((doc) => doc[User.PHONE_NUMBER]);
  }

  static Future<List<User>> getUsers([int limit = 20]) async {
    return User.listFromSnapshots((await userCollection
            .where(User.GHOST, isEqualTo: false)
            .orderBy(User.DONATEDAMOUNT, descending: true)
            .limit(limit)
            .getDocuments())
        .documents);
  }

  static Stream<List<User>> getUsersStream() {
    return userCollection
        .where(User.GHOST, isEqualTo: false)
        .orderBy(User.DONATEDAMOUNT, descending: true)
        .limit(20)
        .snapshots()
        .map((qs) => User.listFromSnapshots(qs.documents));
  }

  static Stream<List<Campaign>> getCampaignFromQueryStream(String query) {
    return campaignsCollection
        .where(Campaign.NAME, isGreaterThanOrEqualTo: query)
        .snapshots()
        .map((qs) => Campaign.listFromSnapshot(qs.documents));
  }

  static Future<SearchResult> getSearchResultFromQuery(String query) async {
    List<Campaign> campaigns = await getCampaignFromQuery(query);
    List<User> users = await getUsersFromQuery(query);
    return SearchResult(campaigns: campaigns, users: users);
  }

  static Future<List<Campaign>> getCampaignFromQuery(String query) async {
    QuerySnapshot qs = await campaignsCollection
        .where(Campaign.NAME, isGreaterThanOrEqualTo: query)
        .getDocuments();

    List<Campaign> campaigns =
        qs.documents.map((doc) => Campaign.fromSnapshot(doc)).toList();

    campaigns.removeWhere((Campaign c) => !c.name.contains(query));

    return campaigns;
  }

  static Future<List<User>> getUsersFromQuery(String query) async {
    QuerySnapshot nameSnapshot = await userCollection
        .where(User.GHOST, isEqualTo: false)
        .where(User.NAME, isGreaterThanOrEqualTo: query)
        .limit(5)
        .getDocuments();

    List<User> nameList =
        nameSnapshot.documents.map(User.fromSnapshot).toList();

    return nameList;
  }

  static Future<void> createSubscription(Campaign campaign, String uid) async {
    await subscribedCampaignsCollection
        .document(uid)
        .collection(CAMPAIGNS)
        .document(campaign.id)
        .setData(campaign.toShortMap());
  }

  static Future<void> deleteSubscription(Campaign campaign, String uid) async {
    // await campaignsCollection
    //     .document(campaign.id)
    //     .updateData({Campaign.SUBSCRIBEDCOUNT: FieldValue.increment(-1)});
    // await userCollection.document(uid).updateData({
    //   User.SUBSCRIBEDCAMPAIGNS: FieldValue.arrayRemove([campaign.id])
    // });
    await subscribedCampaignsCollection
        .document(uid)
        .collection(CAMPAIGNS)
        .document(campaign.id)
        .delete();
  }

  static Stream<List<Campaign>> getSubscribedCampaignsStream(String uid) {
    return subscribedCampaignsCollection
        .document(uid)
        .collection(CAMPAIGNS)
        .snapshots()
        .map((qs) => Campaign.listFromShortSnapshot(qs.documents));
  }

  static Future<List<Campaign>> getSubscribedCampaigns(String uid) async {
    return (await subscribedCampaignsCollection
            .document(uid)
            .collection(CAMPAIGNS)
            .getDocuments())
        .documents
        .map((doc) => Campaign.fromShortSnapshot(doc))
        .toList();
  }

  static Stream<bool> hasSubscribedCampaignStream(String uid, String cid) {
    return subscribedCampaignsCollection
        .document(uid)
        .collection(CAMPAIGNS)
        .document(cid)
        .snapshots()
        .map((doc) => doc.exists);
  }

  static Future<Campaign> getCampaign(String id) async {
    DocumentSnapshot ss = await campaignsCollection.document(id).get();
    return Campaign.fromSnapshot(ss);
  }

  static Stream<Campaign> getCampaignStream(String id) {
    return campaignsCollection
        .document(id)
        .snapshots()
        .map(Campaign.fromSnapshot);
  }

  static Stream<List<Campaign>> getCampaignsFromCategoryStream(int category) {
    return campaignsCollection
        .where(Campaign.CATEGORYID, isEqualTo: category)
        .snapshots()
        .map((qs) => Campaign.listFromSnapshot(qs.documents));
  }

  static Stream<List<Campaign>> getTopCampaignsStream() {
    return campaignsCollection
        .orderBy(Campaign.AMOUNT, descending: true)
        .snapshots()
        .map((qs) => Campaign.listFromSnapshot(qs.documents));
  }

  static Future<List<Campaign>> getTopCampaigns() async {
    return (await campaignsCollection
            .orderBy(Campaign.AMOUNT, descending: true)
            .limit(5)
            .getDocuments())
        .documents
        .map(Campaign.fromSnapshot)
        .toList();
  }

  static Future<void> createCampaign(Campaign campaign) async {
    await campaignsCollection.document(campaign.id).setData(campaign.toMap());
  }

  static Future<void> deleteCampaign(Campaign campaign) async {
    await campaignsCollection.document(campaign.id).delete();
  }

  static Future<List<News>> getNewsFromCampaign(Campaign campaign) async {
    return (await newsCollection
            .where(News.CAMPAIGNID, isEqualTo: campaign.id)
            .getDocuments())
        .documents
        .map((ds) => News.fromSnapshot(ds))
        .toList();
  }

  static Stream<List<News>> getNewsFromCampaignStream(Campaign campaign) {
    return newsCollection
        .where(News.CAMPAIGNID, isEqualTo: campaign.id)
        .snapshots()
        .map((qs) => News.listFromSnapshot(qs.documents));
  }

  static Stream<List<News>> getNews(String uid) {
    return newsFeedCollection
        .document(uid)
        .collection(NEWS)
        .orderBy(News.CREATEDAT, descending: true)
        .snapshots()
        .map((doc) => News.listFromSnapshot(doc.documents));
  }

  static Future<ApiResult> createNews(News news) async {
    try {
      await newsCollection.document(news.id).setData(news.toMap());
      return ApiSuccess();
    } on PlatformException catch (e) {
      return ApiError(e.message);
    }
  }

  static Future<void> createFollow(String meId, String toId) async {
    if (meId == toId) return;
    followingCollection
        .document(meId)
        .collection(USERS)
        .document(toId)
        .setData({"id": toId});
  }

  static Future<void> deleteFollow(String meId, String toId) async {
    if (meId == toId) return;
    followingCollection
        .document(meId)
        .collection(USERS)
        .document(toId)
        .delete();
  }

  static Stream<bool> getFollowStream(String meId, String toId) {
    return followingCollection
        .document(meId)
        .collection(USERS)
        .document(toId)
        .snapshots()
        .map((ss) => ss.exists);
  }

  static Stream<List<String>> getFollowingUsersStream(String uid) {
    return followingCollection
        .document(uid)
        .collection(USERS)
        .snapshots()
        .map((qs) => qs.documents.map((ds) => ds.documentID).toList());
  }

  static Stream<List<String>> getFollowedUsersStream(String uid) {
    return followedCollection
        .document(uid)
        .collection(USERS)
        .snapshots()
        .map((qs) => qs.documents.map((ds) => ds.documentID).toList());
  }

  static Future<List<Campaign>> getCampaignListFromIds(List<String> ids) async {
    List<Campaign> campaigns = [];

    for (String id in ids) {
      campaigns.add(
          Campaign.fromSnapshot(await campaignsCollection.document(id).get()));
    }

    return campaigns;
  }

  static Future<List<Campaign>> getMyCampaigns(String uid) async {
    return (await campaignsCollection
            .where(Campaign.AUTHORID, isEqualTo: uid)
            .getDocuments())
        .documents
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
        .orderBy(Donation.CREATEDAT, descending: true)
        .limit(6)
        .snapshots()
        .map((qs) => Donation.listFromSnapshots(qs.documents));
  }

  static Stream<List<Donation>> getDonationFeedStream(String uid) {
    return donationFeedCollection
        .document(uid)
        .collection(DONATIONS)
        .orderBy(Donation.CREATEDAT, descending: true)
        .limit(20)
        .snapshots()
        .map((qs) => Donation.listFromSnapshots(qs.documents));
  }

  static Stream<List<DonationsGroup>> getDonationsFeedFromDate(String uid,
      [DateTime dt]) {
    DateTime searchedDate = dt ?? DateTime.now();

    DateTime searchStartDate =
        DateTime(searchedDate.year, searchedDate.month, searchedDate.day);
    DateTime searchEndDate = searchStartDate.add(Duration(days: 1));
    return donationFeedCollection
        .document(uid)
        .collection(DONATIONS)
        .where(Donation.CREATEDAT,
            isGreaterThan: Timestamp.fromDate(searchStartDate))
        .where(Donation.CREATEDAT,
            isLessThan: Timestamp.fromDate(searchEndDate))
        .snapshots()
        .map(DonationsGroup.fromQuerySnapshot);
  }

  static Stream<DonationInfo> getDonationInfo() {
    return statisticsCollection
        .document(DONATIONINFO)
        .snapshots()
        .map((ds) => DonationInfo.fromSnapshot(ds));
  }

  static Stream<List<Donation>> getDonationsFromUser(String uid) {
    return donationsCollection
        .where(Donation.USERID, isEqualTo: uid)
        .where(Donation.ISANONYM, isEqualTo: false)
        .orderBy(Donation.CREATEDAT, descending: true)
        .snapshots()
        .map((qs) => Donation.listFromSnapshots(qs.documents));
  }

  static Stream<List<Donation>> getDonationsFromUserLimit(String uid) {
    return donationsCollection
        .where(Donation.USERID, isEqualTo: uid)
        .where(Donation.ISANONYM, isEqualTo: false)
        .orderBy(Donation.CREATEDAT, descending: true)
        .limit(4)
        .snapshots()
        .map((qs) => Donation.listFromSnapshots(qs.documents));
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
          .getDocuments();
      if (qs.documents.isNotEmpty) {
        for (DocumentSnapshot doc in qs.documents) {
          userList.add(
              User.fromSnapshot(await doc.reference.parent().parent().get()));
        }
      }
    }

    return userList;
  }

  static Future<void> addCard({PaymentMethod card, String uid}) {
    return userCollection
        .document(uid)
        .collection(CARDS)
        .document(card.id)
        .setData(card.toJson());
  }

  static Future<void> deleteCard({PaymentMethod card, String uid}) {
    return userCollection
        .document(uid)
        .collection(CARDS)
        .document(card.id)
        .delete();
  }

  static Stream<List<PaymentMethod>> getCards(String uid) {
    return userCollection.document(uid).collection(CARDS).snapshots().map(
        (qs) => qs.documents
            .map((doc) => PaymentMethod.fromJson(doc.data))
            .toList());
  }

  static Stream<bool> hasPaymentMethod(String uid) {
    return userCollection
        .document(uid)
        .collection(CARDS)
        .snapshots()
        .map((qs) => qs.documents.isNotEmpty);
  }

  static Future<List<String>> getFriends(String uid) async {
    return (await friendsCollection
            .document(uid)
            .collection(USERS)
            .getDocuments())
        .documents
        .map((doc) => doc.documentID)
        .toList();
  }

  static Stream<List<String>> getFriendsStream(String uid) {
    return friendsCollection
        .document(uid)
        .collection(USERS)
        .snapshots()
        .map((qs) => qs.documents.map((doc) => doc.documentID).toList());
  }

  static Future<void> saveDeviceToken(String uid, String token) async {
    return (await userCollection
        .document(uid)
        .collection(PRIVATEDATA)
        .document(DATA)
        .setData({User.DEVICETOKEN: token}, merge: true));
  }

  static Future<void> deleteDeviceToken(String uid) async {
    return (await userCollection
        .document(uid)
        .collection(PRIVATEDATA)
        .document(DATA)
        .setData({User.DEVICETOKEN: null}, merge: true));
  }

  static Stream<bool> hasRankingContentForToday(String uid, {DateTime date}) {
    return donationFeedCollection
        .document(uid)
        .collection(Ranking.DAILYRANKINGS)
        .document(Ranking.getFormatedDate(date))
        .snapshots()
        .map((doc) => doc.exists);
  }

  static Stream<FriendsRanking> getFriendsRanking(String uid, {DateTime date}) {
    return donationFeedCollection
        .document(uid)
        .collection(Ranking.DAILYRANKINGS)
        .document(Ranking.getFormatedDate(date))
        .collection(Ranking.USERS)
        .orderBy(Ranking.AMOUNT, descending: true)
        .limit(5)
        .snapshots()
        .map(FriendsRanking.fromQuery);
  }

  static Stream<CampaignsRanking> getCampaignsRanking(String uid,
      {DateTime date}) {
    return donationFeedCollection
        .document(uid)
        .collection(Ranking.DAILYRANKINGS)
        .document(Ranking.getFormatedDate(date))
        .collection(Ranking.CAMPAIGNS)
        .orderBy(Ranking.AMOUNT, descending: true)
        .limit(5)
        .snapshots()
        .map(CampaignsRanking.fromQuery);
  }

  static Stream<int> getDailyDonationsAmount(String uid, {DateTime date}) {
    return donationFeedCollection
        .document(uid)
        .collection(Ranking.DAILYRANKINGS)
        .document(Ranking.getFormatedDate(date))
        .collection(Ranking.USERS)
        .document(uid)
        .snapshots()
        .map(((doc) {
      if (!doc.exists) return 0;
      return doc[Ranking.AMOUNT];
    }));
  }

  static Stream<int> getDailyFriendsDonationsAmount(String uid,
      {DateTime date}) {
    return donationFeedCollection
        .document(uid)
        .collection(Ranking.DAILYRANKINGS)
        .document(Ranking.getFormatedDate(date))
        .snapshots()
        .map(((doc) {
      if (!doc.exists) return 0;
      return doc[Ranking.AMOUNT];
    }));
  }
}
