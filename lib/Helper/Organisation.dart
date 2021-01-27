import 'package:cloud_firestore/cloud_firestore.dart';

class Organisation {
  final String name, imgUrl, thumbnailUrl, id, description, website;

  static final String NAME = "username",
      IMAGEURL = "image_url",
      THUMBNAIL_URL = "thumbnail_url",
      DESCRIPTION = "description",
      WEBSITE = "website";

  Organisation(
      {this.name,
      this.imgUrl,
      this.thumbnailUrl,
      this.id,
      this.description,
      this.website});

  factory Organisation.fromMap(DocumentSnapshot doc) {
    return Organisation(
        name: doc.data()[NAME],
        imgUrl: doc.data()[IMAGEURL],
        thumbnailUrl: doc.data()[THUMBNAIL_URL],
        id: doc.id,
        description: doc.data()[DESCRIPTION] ?? "",
        website: doc.data()[WEBSITE]);
  }
}
