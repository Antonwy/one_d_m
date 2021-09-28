import 'package:cloud_firestore/cloud_firestore.dart';

class Organization {
  final String name, imgUrl, thumbnailUrl, id, description, website;

  static final String NAME = "name",
      IMAGEURL = "image_url",
      THUMBNAIL_URL = "thumbnail_url",
      DESCRIPTION = "description",
      WEBSITE = "website";

  Organization(
      {this.name,
      this.imgUrl,
      this.thumbnailUrl,
      this.id,
      this.description,
      this.website});

  factory Organization.fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data();
    return Organization(
        name: data[NAME],
        imgUrl: data[IMAGEURL],
        thumbnailUrl: data[THUMBNAIL_URL],
        id: doc.id,
        description: data[DESCRIPTION] ?? "",
        website: data[WEBSITE]);
  }

  factory Organization.fromJson(Map<String, dynamic> map) {
    return Organization(
        name: map[NAME],
        imgUrl: map[IMAGEURL],
        thumbnailUrl: map[THUMBNAIL_URL],
        id: map['id'],
        description: map[DESCRIPTION] ?? "",
        website: map[WEBSITE]);
  }

  static List<Organization> listFromJson(List<Map<String, dynamic>> list) {
    return list.map((map) => Organization.fromJson(map)).toList();
  }
}
