import 'package:cloud_firestore/cloud_firestore.dart';

class Organisation {
  final String name, imgUrl, id, description, website;

  static final String NAME = "username",
      IMAGEURL = "image_url",
      DESCRIPTION = "description",
      WEBSITE = "website";

  Organisation(
      {this.name, this.imgUrl, this.id, this.description, this.website});

  factory Organisation.fromMap(DocumentSnapshot doc) {
    return Organisation(
            name: doc.data()[NAME],
            imgUrl: doc.data()[IMAGEURL] ?? "",
            id: doc.id,
            description: doc.data()[DESCRIPTION] ?? "",
            website: doc.data()[WEBSITE]) ??
        "";
  }
}
