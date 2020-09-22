import 'package:cloud_firestore/cloud_firestore.dart';

class Organisation {
  final String name, imgUrl, id, description, website;

  static final String NAME = "name",
      IMAGEURL = "image_url",
      DESCRIPTION = "description",
      WEBSITE = "website";

  Organisation(
      {this.name, this.imgUrl, this.id, this.description, this.website});

  factory Organisation.fromMap(DocumentSnapshot doc) {
    return Organisation(
        name: doc[NAME],
        imgUrl: doc[IMAGEURL],
        id: doc.documentID,
        description: doc[DESCRIPTION],
        website: doc[WEBSITE]);
  }
}
