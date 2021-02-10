import 'package:cloud_firestore/cloud_firestore.dart';

class Campaign {
  final String name, description, shortDescription, city;
  final DateTime createdAt;
  final int amount, subscribedCount, categoryId;
  final String authorId, id, imgUrl, thumbnailUrl, adminId;
  final List<String> moreImages;
  final List<String> effects;
  final List<String> donationEffects;

  static final String ID = "id",
      NAME = "title",
      DESCRIPTION = "description",
      SHORTDESCRIPTION = "short_description",
      SUBSCRIBEDCOUNT = "subscribed_count",
      CITY = "city",
      CREATEDAT = "created_at",
      AUTHORID = "authorId",
      ADMINID = "adminId",
      AMOUNT = "current_amount",
      IMAGEURL = "image_url",
      MOREIMAGES = "more_image_urls",
      THUMBNAILURL = "thumbnail_url",
      EFFECTS = "effects",
      DONATION_EFFECTS = "donation_effects",
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
      this.adminId,
      this.subscribedCount,
      this.amount,
      this.imgUrl,
      this.moreImages,
      this.thumbnailUrl,
      this.categoryId,
      this.donationEffects,
      this.effects});

  static Campaign fromSnapshot(DocumentSnapshot snapshot) {
    return Campaign(
        id: snapshot.id,
        name: snapshot.data()[NAME],
        amount: snapshot.data()[AMOUNT],
        description: snapshot.data()[DESCRIPTION],
        shortDescription: snapshot.data()[SHORTDESCRIPTION],
        subscribedCount: snapshot.data()[SUBSCRIBEDCOUNT],
        createdAt: (snapshot.data()[CREATEDAT] as Timestamp).toDate(),
        imgUrl: snapshot.data()[IMAGEURL],
        thumbnailUrl: snapshot.data()[THUMBNAILURL] ?? '',
        authorId: snapshot.data()[AUTHORID],
        adminId: snapshot.data()[ADMINID],
        categoryId: snapshot.data()[CATEGORYID],
        moreImages: snapshot.data()[MOREIMAGES] == null
            ? []
            : List.from(snapshot.data()[MOREIMAGES]),
        effects: snapshot.data()[EFFECTS] == null
            ? []
            : List.from(snapshot.data()[EFFECTS]),
        donationEffects: snapshot.data()[DONATION_EFFECTS] == null
            ? []
            : List.from(snapshot.data()[DONATION_EFFECTS]));
  }

  static Campaign fromShortSnapshot(DocumentSnapshot snapshot) {
    return Campaign(
      id: snapshot.id,
      name: snapshot.data()[NAME],
      shortDescription: snapshot.data()[SHORTDESCRIPTION],
      imgUrl: snapshot.data()[IMAGEURL],
    );
  }

  static List<Campaign> listFromSnapshot(List<DocumentSnapshot> list) {
    return list.map(Campaign.fromSnapshot).toList();
  }

  static List<Campaign> listFromShortSnapshot(List<DocumentSnapshot> list) {
    return list.map(Campaign.fromShortSnapshot).toList();
  }

  Map<String, dynamic> toMap() {
    return {
      ID: id,
      NAME: name,
      DESCRIPTION: description,
      SHORTDESCRIPTION: shortDescription,
      AUTHORID: authorId,
      IMAGEURL: imgUrl,
    };
  }

  Map<String, dynamic> toShortMap() {
    return {
      NAME: name,
      SHORTDESCRIPTION: shortDescription,
      IMAGEURL: imgUrl,
    };
  }

  @override
  String toString() {
    return 'Campaign{name: $name, description: $description, city: $city, imgUrl: $imgUrl, endDate: $createdAt, amount: $amount, id: $id, authorId: $authorId}';
  }

  @override
  bool operator ==(other) {
    if (other is Campaign) return other.id == this.id;
    return false;
  }
}
