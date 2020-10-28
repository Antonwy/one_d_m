import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String email, name, password, id, phoneNumber, imgUrl, thumbnailUrl;
  int donatedAmount;
  bool admin, ghost;
  List<String> subscribedCampaignsIds = [];

  static final String NAME = "name",
      EMAIL = "email_address",
      PHONE_NUMBER = "phone_number",
      ADMIN = "admin",
      SUBSCRIBEDCAMPAIGNS = "subscribed_campaigns",
      DONATEDAMOUNT = "donated_amount",
      IMAGEURL = "image_url",
      THUMBNAILURL = "thumbnail_url",
      DEVICETOKEN = "device_token",
      GHOST = "ghost",
      NATIVE_AD_IMPRESSIONS = "native_ad_impressions",
      INTERSTITIAL_IMPRESSIONS = "interstitial_impressions";

  User(
      {this.email,
      this.name,
      this.password,
      this.id,
      this.donatedAmount = 0,
      this.phoneNumber,
      this.admin,
      this.ghost = false,
      List<String> subscribedCampaignsIds,
      this.imgUrl,
      this.thumbnailUrl})
      : this.subscribedCampaignsIds = subscribedCampaignsIds ?? [];

  static User fromSnapshot(DocumentSnapshot snapshot) {
    if (snapshot.data == null) return User();
    return User(
        id: snapshot.documentID,
        name: snapshot[User.NAME] ?? "No name",
        admin: snapshot[User.ADMIN],
        ghost: snapshot[User.GHOST] ?? false,
        donatedAmount: snapshot[DONATEDAMOUNT],
        subscribedCampaignsIds: snapshot[User.SUBSCRIBEDCAMPAIGNS] == null
            ? []
            : List.from(snapshot[User.SUBSCRIBEDCAMPAIGNS]),
        imgUrl: snapshot[IMAGEURL],
        thumbnailUrl: snapshot[THUMBNAILURL]);
  }

  static List<User> listFromSnapshots(List<DocumentSnapshot> snapshots) {
    return snapshots.map((ss) => fromSnapshot(ss)).toList();
  }

  Map<String, dynamic> userInfoToMap() {
    return {
      "id": id,
      NAME: name,
      IMAGEURL: imgUrl,
      THUMBNAILURL: thumbnailUrl
    };
  }

  Map<String, dynamic> publicDataToMap() {
    return {
      NAME: name,
      ADMIN: false,
      IMAGEURL: imgUrl,
      SUBSCRIBEDCAMPAIGNS: [],
      DONATEDAMOUNT: 0,
      GHOST: false
    };
  }

  Map<String, dynamic> privateDataToMap() {
    return {
      EMAIL: email,
      PHONE_NUMBER: phoneNumber,
    };
  }

  @override
  String toString() {
    return 'User{email: $email, name: $name, password: $password, profileImage: $imgUrl, id: $id, ghost: $ghost}';
  }
}
