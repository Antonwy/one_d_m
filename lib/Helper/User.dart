import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:one_d_m/Helper/Campaign.dart';

class User {
  String email, firstname, lastname, password;
  String imgUrl;
  String id;
  int donatedAmount;
  bool admin;
  List<String> subscribedCampaignsIds = List<String>();
  List<Campaign> subscribedCampaigns = List<Campaign>();

  static final String FIRSTNAME = "first_name",
      LASTNAME = "last_name",
      EMAIL = "email_address",
      ADMIN = "admin",
      SUBSCRIBEDCAMPAIGNS = "subscribed_campaigns",
      DONATEDAMOUNT = "donated_amount",
      IMAGEURL = "image_url";

  User({
    this.email,
    this.firstname,
    this.lastname,
    this.password,
    this.id,
    this.subscribedCampaignsIds,
    this.donatedAmount = 0,
    this.imgUrl,
    this.admin,
  });

  static User fromSnapshot(DocumentSnapshot snapshot) {
    if (snapshot.data == null) return User();
    return User(
        id: snapshot.documentID,
        firstname: snapshot[User.FIRSTNAME],
        lastname: snapshot[User.LASTNAME],
        email: snapshot[User.EMAIL],
        admin: snapshot[User.ADMIN],
        donatedAmount: snapshot[DONATEDAMOUNT],
        subscribedCampaignsIds: snapshot[User.SUBSCRIBEDCAMPAIGNS] == null
            ? []
            : List.from(snapshot[User.SUBSCRIBEDCAMPAIGNS]),
        imgUrl: snapshot[IMAGEURL]);
  }

  static List<User> listFromSnapshots(List<DocumentSnapshot> snapshots) {
    return snapshots.map((ss) => fromSnapshot(ss)).toList();
  }

  Map<String, dynamic> toMap() {
    return {
      FIRSTNAME: firstname,
      LASTNAME: lastname,
      EMAIL: email,
      ADMIN: false,
      IMAGEURL: imgUrl,
      SUBSCRIBEDCAMPAIGNS: []
    };
  }

  @override
  String toString() {
    return 'User{email: $email, firstname: $firstname, lastname: $lastname, password: $password, profileImage: $imgUrl, id: $id}';
  }
}
