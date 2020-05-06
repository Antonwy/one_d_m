import 'package:cloud_firestore/cloud_firestore.dart';

class Campaign {
  final String name, description, shortDescription, city;
  final DateTime createdAt;
  final int amount, subscribedCount, categoryId;
  final String authorId, id, imgUrl, thumbnailUrl;

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
      THUMBNAILURL = "thumbnail_url",
      FINALAMOUNT = "target_amount",
      CATEGORYID = "category_id";

  Campaign(
      {this.id,
      this.name,
      this.description,
      this.shortDescription,
      this.city,
      this.createdAt,
      this.authorId,
      this.subscribedCount,
      this.amount,
      this.imgUrl,
      this.thumbnailUrl,
      this.categoryId});

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
        imgUrl: snapshot[IMAGEURL],
        thumbnailUrl: snapshot[THUMBNAILURL],
        authorId: snapshot[AUTHORID],
        categoryId: snapshot[CATEGORYID]);
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
      IMAGEURL: imgUrl,
      CATEGORYID: 0
    };
  }

  @override
  String toString() {
    return 'Campaign{name: $name, description: $description, city: $city, imgUrl: $imgUrl, endDate: $createdAt, amount: $amount, id: $id, authorId: $authorId}';
  }
}
