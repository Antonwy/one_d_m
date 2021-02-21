import 'package:cloud_firestore/cloud_firestore.dart';

class Campaign {
  final String name, description, shortDescription, city, unit, dvAnimation;
  final DateTime createdAt;
  final int amount, subscribedCount, categoryId, dvController, maxAnimCount;
  final String authorId,
      id,
      imgUrl,
      thumbnailUrl,
      adminId,
      shortVideoUrl,
      longVideoUrl;
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
      DONATIONIMAGES = "donation_images",
      THUMBNAILURL = "thumbnail_url",
      EFFECTS = "effects",
      DONATION_EFFECTS = "donation_effects",
      FINALAMOUNT = "target_amount",
      CATEGORYID = "category_id",
      SHORTVIDEOURL = "short_video_url",
      LONGVIDEOURL = "long_video_url",
      DV_ANIMATION = "dv_animation",
      MAX_ANIM_COUNT = "max_anim_count",
      DV_CONTROLLER = "dv_controller",
      UNIT = "donation_unit";

  Campaign(
      {this.id,
      this.unit,
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
      this.dvAnimation,
      this.thumbnailUrl,
      this.maxAnimCount,
      this.dvController,
      this.categoryId,
      this.shortVideoUrl,
      this.longVideoUrl,
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
      shortVideoUrl: snapshot.data()[SHORTVIDEOURL],
      longVideoUrl: snapshot.data()[LONGVIDEOURL],
      adminId: snapshot.data()[ADMINID],
      unit: snapshot.data()[UNIT],
      dvController: snapshot.data()[DV_CONTROLLER] ?? 1,
      maxAnimCount: snapshot.data()[MAX_ANIM_COUNT] ?? 3,
      categoryId: snapshot.data()[CATEGORYID],
      dvAnimation: snapshot.data()[DV_ANIMATION] ?? '',
      moreImages: snapshot.data()[MOREIMAGES] == null
          ? []
          : List.from(snapshot.data()[MOREIMAGES]),
      effects: snapshot.data()[EFFECTS] == null
          ? []
          : List.from(snapshot.data()[EFFECTS]),
      donationEffects: snapshot.data()[DONATION_EFFECTS] == null
          ? []
          : List.from(snapshot.data()[DONATION_EFFECTS]),
    );
  }

  static Campaign fromShortSnapshot(DocumentSnapshot snapshot) {
    return Campaign(
        id: snapshot.id,
        name: snapshot.data()[NAME],
        shortDescription: snapshot.data()[SHORTDESCRIPTION],
        imgUrl: snapshot.data()[IMAGEURL],
        longVideoUrl: snapshot.data()[LONGVIDEOURL],
        shortVideoUrl: snapshot.data()[SHORTVIDEOURL]);
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
      SHORTVIDEOURL: shortVideoUrl,
      LONGVIDEOURL: longVideoUrl,
    };
  }

  Map<String, dynamic> toShortMap() {
    return {
      NAME: name,
      SHORTDESCRIPTION: shortDescription,
      IMAGEURL: imgUrl,
      SHORTVIDEOURL: shortVideoUrl,
      LONGVIDEOURL: longVideoUrl,
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
