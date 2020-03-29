import 'package:cloud_firestore/cloud_firestore.dart';

class Campaign {
  String name, description, shortDescription, city, imgUrl;
  DateTime createdAt;
  int amount, finalAmount;
  String authorId, id;
  bool subscribed;

  static final String ID = "id",
      NAME = "title",
      DESCRIPTION = "description",
      SHORTDESCRIPTION = "short_description",
      CITY = "city",
      CREATEDAT = "created_at",
      AUTHORID = "authorId",
      AMOUNT = "current_amount",
      IMAGEURL = "image_url",
      FINALAMOUNT = "target_amount";

  Campaign({
    this.id,
    this.name,
    this.description,
    this.shortDescription,
    this.city,
    this.createdAt,
    this.authorId,
    this.amount = 10000,
    this.imgUrl,
    this.finalAmount = 200000,
    this.subscribed = false,
  });

  static Campaign fromSnapshot(DocumentSnapshot snapshot) {
    return Campaign(
        id: snapshot.documentID,
        name: snapshot[NAME],
        description: snapshot[DESCRIPTION],
        city: snapshot[CITY],
        shortDescription: snapshot[SHORTDESCRIPTION],
        createdAt:
            DateTime.fromMicrosecondsSinceEpoch(snapshot[CREATEDAT] ?? 0),
        imgUrl: snapshot[IMAGEURL],
        authorId: snapshot[AUTHORID]);
  }

  static Campaign fromShortSnapshot(DocumentSnapshot snapshot) {
    return Campaign(
      id: snapshot.documentID,
      name: snapshot[NAME],
      imgUrl: snapshot[IMAGEURL],
    );
  }

  static List<Campaign> listFromSnapshot(List<DocumentSnapshot> list) {
    return list.map(Campaign.fromSnapshot).toList();
  }

  Map<String, dynamic> toMap() {
    return {
      NAME: name,
      DESCRIPTION: description,
      SHORTDESCRIPTION: shortDescription,
      CITY: city,
      CREATEDAT: DateTime.now().millisecondsSinceEpoch,
      AUTHORID: authorId,
      AMOUNT: amount,
      FINALAMOUNT: finalAmount,
      IMAGEURL: imgUrl
    };
  }

  static List<Campaign> listFromShortSnapshot(List<DocumentSnapshot> list) {
    return list.map(Campaign.fromShortSnapshot).toList();
  }

  Map<String, dynamic> toShortMap() {
    return {NAME: name, AMOUNT: amount, IMAGEURL: imgUrl};
  }

  void toggleSubscribed() {
    subscribed = !subscribed;
  }

  @override
  String toString() {
    return 'Campaign{name: $name, description: $description, city: $city, imgUrl: $imgUrl, endDate: $createdAt, amount: $amount, finalAmount: $finalAmount, id: $id, authorId: $authorId, subscribed: $subscribed}';
  }
}
