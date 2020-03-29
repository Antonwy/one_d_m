import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String username, email, firstname, lastname, password;
  String imgUrl;
  String id;
  bool admin;

  static final String FIRSTNAME = "first_name",
      LASTNAME = "last_name",
      EMAIL = "email_address",
      ADMIN = "admin",
      IMAGEURL = "image_url";

  User(
      {this.username,
      this.email,
      this.firstname,
      this.lastname,
      this.password,
      this.id,
      this.imgUrl,
      this.admin,});

  static User fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> map = snapshot.data;
    return User(
        id: snapshot.documentID,
        firstname: map[User.FIRSTNAME],
        lastname: map[User.LASTNAME],
        email: map[User.EMAIL],
        admin: map[User.ADMIN],
        imgUrl: map[IMAGEURL]);
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
      IMAGEURL: imgUrl
    };
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User{username: $username, email: $email, firstname: $firstname, lastname: $lastname, password: $password, profileImage: $imgUrl, id: $id}';
  }
}
