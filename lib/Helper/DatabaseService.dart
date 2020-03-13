import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:one_d_m/Helper/API/ApiError.dart';
import 'package:one_d_m/Helper/API/ApiResult.dart';
import 'package:one_d_m/Helper/API/ApiSuccess.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/StorageService.dart';
import 'Campaign.dart';
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
      CAMPAIGNNEWS = "campaign_news";

  final String uid;
  final CollectionReference userCollection =
      Firestore.instance.collection(USER);
  final CollectionReference campaignsCollection =
      Firestore.instance.collection(CAMPAIGNS);
  final CollectionReference newsCollection =
      Firestore.instance.collection(NEWS);
  final CollectionReference subscribedCampaignsCollection =
      Firestore.instance.collection(SUBSCRIBEDCAMPAIGNS);
  final CollectionReference feedCollection =
      Firestore.instance.collection(FEED);
  final CollectionReference followingCollection =
      Firestore.instance.collection(FOLLOWING);
  final CollectionReference followedCollection =
      Firestore.instance.collection(FOLLOWED);

  DatabaseService([this.uid]);

  Future<void> addUser(User user) async {
    return userCollection.document(uid).setData(user.toMap());
  }

  Future<User> getUser() async {
    return User.fromSnapshot(await userCollection.document(uid).get());
  }

  Future<List<User>> getUsers() async {
    return User.listFromSnapshots(
        (await userCollection.limit(20).getDocuments()).documents);
  }

  Stream<List<Campaign>> getCampaignsStream() {
    return campaignsCollection
        .snapshots()
        .map((QuerySnapshot qs) => Campaign.listFromSnapshot(qs.documents));
  }

  Stream<List<Campaign>> getCampaignFromQuery(String query) {
    return campaignsCollection
        .where(Campaign.NAME, isGreaterThanOrEqualTo: query)
        .snapshots()
        .map((qs) => Campaign.listFromSnapshot(qs.documents));
  }

  Stream<DocumentSnapshot> hasSubscribedCampaign(String campaignId) {
    return subscribedCampaignsCollection
        .document(uid)
        .collection(CAMPAIGNS)
        .document(campaignId)
        .snapshots();
  }

  Future<void> createSubscription(Campaign campaign) async {
    await subscribedCampaignsCollection
        .document(uid)
        .collection(CAMPAIGNS)
        .document(campaign.id)
        .setData(campaign.toShortMap());
  }

  Future<void> deleteSubscription(Campaign campaign) async {
    await subscribedCampaignsCollection
        .document(uid)
        .collection(CAMPAIGNS)
        .document(campaign.id)
        .delete();
  }

  Stream<List<Campaign>> getSubscribedCampaignsStream() {
    return subscribedCampaignsCollection
        .document(uid)
        .collection(CAMPAIGNS)
        .snapshots()
        .map((qs) => Campaign.listFromShortSnapshot(qs.documents));
  }

  Stream<List<Campaign>> getMyCampaignsStream() {
    return campaignsCollection
        .where("authorId", isEqualTo: uid)
        .snapshots()
        .map((qs) => Campaign.listFromShortSnapshot(qs.documents));
  }

  Future<Campaign> getCampaign(String id) async {
    DocumentSnapshot ss = await campaignsCollection.document(id).get();
    return Campaign.fromSnapshot(ss);
  }

  Future<DocumentReference> createCampaign(Campaign campaign) async {
    DocumentReference ref = await campaignsCollection.add(campaign.toMap());
    await subscribedCampaignsCollection
        .document(campaign.authorId)
        .collection(CAMPAIGNS)
        .document(ref.documentID)
        .setData(campaign.toShortMap());
  }

  Future<void> deleteCampaign(Campaign campaign) async {
    await campaignsCollection.document(campaign.id).delete();
    await StorageService().deleteOld(campaign.imgUrl);
  }

  Stream<List<News>> getNewsFromCampaignStream(Campaign campaign) {
    return newsCollection
        .document(campaign.id)
        .collection(CAMPAIGNNEWS)
        .snapshots()
        .map((qs) => News.listFromSnapshot(qs.documents));
  }

  Stream<List<News>> getNewsStream() {
    return feedCollection
        .document(uid)
        .collection(NEWS)
        .snapshots()
        .map((qs) => News.listFromSnapshot(qs.documents));
  }

  Future<ApiResult> createNews(News news) async {
    try {
      await newsCollection
          .document(news.campaignId)
          .collection(CAMPAIGNNEWS)
          .add(news.toMap());
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
        .setData(user.toMap());
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

  Stream<List<User>> getFollowingUsersStream(User user) {
    return followingCollection
        .document(user.id)
        .collection(USERS)
        .snapshots()
        .map((qs) => User.listFromSnapshots(qs.documents));
  }

  Stream<List<User>> getFollowedUsersStream(User user) {
    return followedCollection
        .document(user.id)
        .collection(USERS)
        .snapshots()
        .map((qs) => User.listFromSnapshots(qs.documents));
  }

  DocumentReference get userReference => userCollection.document(uid);
}
