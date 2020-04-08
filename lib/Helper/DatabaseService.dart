import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:one_d_m/Helper/API/ApiError.dart';
import 'package:one_d_m/Helper/API/ApiResult.dart';
import 'package:one_d_m/Helper/API/ApiSuccess.dart';
import 'package:one_d_m/Helper/DonationInfo.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/SearchResult.dart';
import 'package:one_d_m/Helper/StorageService.dart';
import 'Campaign.dart';
import 'Donation.dart';
import 'User.dart';

class DatabaseService {
  static final String CAMPAIGNS = "campaigns",
      USER = "user",
      USERS = "users",
      NEWS = "news",
      FEED = "feed",
      SUBSCRIBEDCAMPAIGNS = "subscribed_campaigns",
      FOLLOWING = "following",
      FOLLOWED = "followed",
      CAMPAIGNNEWS = "campaign_news",
      DONATIONS = "donations",
      DONATIONFEED = "donation_feed";

  final String uid;
  static final Firestore firestore = Firestore.instance;
  final CollectionReference userCollection = firestore.collection(USER);
  final CollectionReference campaignsCollection =
      firestore.collection(CAMPAIGNS);
  final CollectionReference newsCollection = firestore.collection(NEWS);
  final CollectionReference subscribedCampaignsCollection =
      firestore.collection(SUBSCRIBEDCAMPAIGNS);
  final CollectionReference feedCollection = firestore.collection(FEED);
  final CollectionReference followingCollection =
      firestore.collection(FOLLOWING);
  final CollectionReference followedCollection = firestore.collection(FOLLOWED);
  final CollectionReference donationsCollection =
      firestore.collection(DONATIONS);
  final CollectionReference donationFeedCollection =
      firestore.collection(DONATIONFEED);

  DatabaseService([this.uid]);

  // HELPER!!!
  Future<void> updateDatabase() async {
    for (User user in await getUsers()) {
      QuerySnapshot qs = await followingCollection
          .document(user.id)
          .collection(USERS)
          .getDocuments();

      for (DocumentSnapshot ds in qs.documents) {
        await followingCollection
            .document(user.id)
            .collection(USERS)
            .document(ds.documentID)
            .setData({"id": ds.documentID});
      }
    }
  }

  // HELPER!!!
  Future<void> updateDatabaseDonations() async {}

  Future<void> addUser(User user) async {
    return userCollection.document(uid).setData(user.toMap());
  }

  Future<void> updateUser(User user) async {
    return userCollection.document(uid).updateData({
      User.FIRSTNAME: user.firstname,
      User.LASTNAME: user.lastname,
      User.IMAGEURL: user.imgUrl,
    });
  }

  Future<User> getUser() async {
    return User.fromSnapshot(await userCollection.document(uid).get());
  }

  Future<User> getUserFromId(String userId) async {
    return User.fromSnapshot(await userCollection.document(userId).get());
  }

  Stream<User> getUserStream(String id) {
    return userCollection
        .document(id)
        .snapshots()
        .map((ds) => User.fromSnapshot(ds));
  }

  Future<List<User>> getUsers() async {
    return User.listFromSnapshots(
        (await userCollection.limit(20).getDocuments()).documents);
  }

  Stream<List<Campaign>> getCampaignFromQueryStream(String query) {
    return campaignsCollection
        .where(Campaign.NAME, isGreaterThanOrEqualTo: query)
        .snapshots()
        .map((qs) => Campaign.listFromSnapshot(qs.documents));
  }

  Future<SearchResult> getSearchResultFromQuery(String query) async {
    List<Campaign> campaigns = await getCampaignFromQuery(query);
    List<User> users = await getUsersFromQuery(query);
    return SearchResult(campaigns: campaigns, users: users);
  }

  Future<List<Campaign>> getCampaignFromQuery(String query) async {
    QuerySnapshot qs = await campaignsCollection
        .where(Campaign.NAME, isGreaterThanOrEqualTo: query)
        .getDocuments();

    List<Campaign> campaigns =
        qs.documents.map((doc) => Campaign.fromSnapshot(doc)).toList();

    campaigns.removeWhere((Campaign c) => !c.name.contains(query));

    return campaigns;
  }

  Future<List<User>> getUsersFromQuery(String query) async {
    QuerySnapshot firstnameSnapshot = await userCollection
        .where(User.FIRSTNAME, isGreaterThanOrEqualTo: query)
        .limit(5)
        .getDocuments();
    QuerySnapshot lastnameSnapshot = await userCollection
        .where(User.LASTNAME, isGreaterThanOrEqualTo: query)
        .limit(5)
        .getDocuments();

    List<User> firstnameList =
        firstnameSnapshot.documents.map(User.fromSnapshot).toList();

    Map<String, User> userMap = Map.fromIterable(firstnameList,
        key: (user) => user.id, value: (user) => user);

    List<User> lastnameList =
        lastnameSnapshot.documents.map(User.fromSnapshot).toList();

    userMap.addAll(Map.fromIterable(lastnameList,
        key: (user) => user.id, value: (user) => user));

    userMap.removeWhere((String str, User user) =>
        !user.firstname.contains(query) && !user.lastname.contains(query));
    return userMap.values.toList();
  }

  Future<void> createSubscription(Campaign campaign) async {
    feedCollection.document(uid).collection(NEWS);

    firestore.runTransaction((tx) async {
      campaignsCollection
          .document(campaign.id)
          .updateData({Campaign.SUBSCRIBEDCOUNT: FieldValue.increment(1)});
    });

    await userCollection.document(uid).updateData({
      User.SUBSCRIBEDCAMPAIGNS: FieldValue.arrayUnion([campaign.id])
    });
  }

  Future<void> deleteSubscription(Campaign campaign) async {
    firestore.runTransaction((tx) async {
      campaignsCollection
          .document(campaign.id)
          .updateData({Campaign.SUBSCRIBEDCOUNT: FieldValue.increment(-1)});
    });
    await userCollection.document(uid).updateData({
      User.SUBSCRIBEDCAMPAIGNS: FieldValue.arrayRemove([campaign.id])
    });
  }

  Future<List<Campaign>> getSubscribedCampaigns(User user) async {
    List<Campaign> campaigns = [];
    for (String id in user.subscribedCampaignsIds) {
      campaigns.add(
          Campaign.fromSnapshot(await campaignsCollection.document(id).get()));
    }

    return campaigns;
  }

  Future<Campaign> getCampaign(String id) async {
    DocumentSnapshot ss = await campaignsCollection.document(id).get();
    return Campaign.fromSnapshot(ss);
  }

  Stream<Campaign> getCampaignStream(String id) {
    return campaignsCollection
        .document(id)
        .snapshots()
        .map(Campaign.fromSnapshot);
  }

  Future<DocumentReference> createCampaign(Campaign campaign) async {
    await campaignsCollection.add(campaign.toMap());
  }

  Future<void> deleteCampaign(Campaign campaign) async {
    await campaignsCollection.document(campaign.id).delete();
    await StorageService().deleteOld(campaign.imgUrl);
  }

  Future<List<News>> getNewsFromCampaign(Campaign campaign) async {
    return (await newsCollection
            .where(News.CAMPAIGNID, isEqualTo: campaign.id)
            .getDocuments())
        .documents
        .map((ds) => News.fromSnapshot(ds))
        .toList();
  }

  Future<List<News>> getNews(User user) async {
    List<News> news = [];

    for (String id in user.subscribedCampaignsIds) {
      news.addAll(await getNewsFromCampaign(Campaign(id: id)));
    }

    return news;
  }

  Future<ApiResult> createNews(News news) async {
    try {
      await newsCollection.add(news.toMap());
      return ApiSuccess();
    } on PlatformException catch (e) {
      return ApiError(e.message);
    }
  }

  Future<void> createFollow(User user) async {
    followingCollection
        .document(uid)
        .collection(USERS)
        .document(user.id)
        .setData({"id": user.id});
  }

  Future<void> deleteFollow(User user) async {
    followingCollection
        .document(uid)
        .collection(USERS)
        .document(user.id)
        .delete();
  }

  Stream<bool> getFollowStream(User user) {
    return followingCollection
        .document(uid)
        .collection(USERS)
        .document(user.id)
        .snapshots()
        .map((ss) => ss.exists);
  }

  Stream<List<String>> getFollowingUsersStream(User user) {
    return followingCollection
        .document(user.id)
        .collection(USERS)
        .snapshots()
        .map((qs) => qs.documents.map((ds) => ds.documentID).toList());
  }

  Stream<List<String>> getFollowedUsersStream(User user) {
    return followedCollection
        .document(user.id)
        .collection(USERS)
        .snapshots()
        .map((qs) => qs.documents.map((ds) => ds.documentID).toList());
  }

  Future<List<Campaign>> getCampaignListFromIds(List<String> ids) async {
    List<Campaign> campaigns = [];

    for (String id in ids) {
      campaigns.add(
          Campaign.fromSnapshot(await campaignsCollection.document(id).get()));
    }

    return campaigns;
  }

  Future<void> donate(Donation donation) async {
    await donationsCollection.add(donation.toMap());
  }

  Stream<List<Donation>> getDonationFromCampaignStream(String campaignId) {
    return donationsCollection
        .where(Donation.CAMPAIGNID, isEqualTo: campaignId)
        .limit(5)
        .snapshots()
        .map((qs) => Donation.listFromSnapshots(qs.documents));
  }

  Stream<List<Donation>> getDonationFeedStream() {
    return donationFeedCollection
        .document(uid)
        .collection(DONATIONS)
        .limit(5)
        .snapshots()
        .map((qs) => Donation.listFromSnapshots(qs.documents));
  }

  Stream<DonationInfo> getDonationInfo() {
    return donationsCollection
        .document("info")
        .snapshots()
        .map((ds) => DonationInfo.fromSnapshot(ds));
  }

  Stream<List<Donation>> getDonationsFromUser(User user) {
    return donationsCollection
        .where(Donation.USERID, isEqualTo: user.id)
        .orderBy(Donation.CREATEDAT, descending: true)
        .snapshots()
        .map((qs) => Donation.listFromSnapshots(qs.documents));
  }

  DocumentReference get userReference => userCollection.document(uid);
}
