import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:one_d_m/Helper/ImageUrl.dart';

class Campaign {
  final String name, description, shortDescription, city;
  final DateTime createdAt;
  final int amount, subscribedCount;
  final String authorId, id;
  ImageUrl imgUrl;

  static final String ID = "id",
      NAME = "title",
      DESCRIPTION = "description",
      SHORTDESCRIPTION = "short_description",
      SUBSCRIBEDCOUNT = "subscribed_count",
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
    this.subscribedCount,
    this.amount,
    String url,
  }) {
    this.imgUrl = ImageUrl(url);
  }

  static Campaign fromSnapshot(DocumentSnapshot snapshot) {
    return Campaign(
        id: snapshot.documentID,
        name: snapshot[NAME],
        amount: snapshot[AMOUNT],
        description: snapshot[DESCRIPTION],
        city: snapshot[CITY],
        shortDescription: snapshot[SHORTDESCRIPTION],
        subscribedCount: snapshot[SUBSCRIBEDCOUNT] ?? 0,
        createdAt: (snapshot[CREATEDAT] as Timestamp).toDate(),
        url: snapshot[IMAGEURL],
        authorId: snapshot[AUTHORID]);
  }

  static List<Campaign> listFromSnapshot(List<DocumentSnapshot> list) {
    return list.map(Campaign.fromSnapshot).toList();
  }

  Map<String, dynamic> toMap() {
    return {
      NAME: name,
      DESCRIPTION: description,
      SHORTDESCRIPTION: shortDescription,
      SUBSCRIBEDCOUNT: 0,
      CITY: city,
      CREATEDAT: Timestamp.now(),
      AUTHORID: authorId,
      AMOUNT: amount,
      IMAGEURL: imgUrl.url,
    };
  }

  @override
  String toString() {
    return 'Campaign{name: $name, description: $description, city: $city, imgUrl: $imgUrl, endDate: $createdAt, amount: $amount, id: $id, authorId: $authorId}';
  }
}
