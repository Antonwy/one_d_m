import 'dart:convert';
import 'dart:io';

class User {
  String username, email, firstname, lastname, password;
  File profileImage;
  int id;

  User(
      {this.username,
      this.email,
      this.firstname,
      this.lastname,
      this.password,
      this.id = 0,
      this.profileImage});

  static User fromJson(Map<String, dynamic> json) {
    return User(
        username: json["data"]["username"],
        firstname: json["data"]["first_name"],
        lastname: json["data"]["last_name"],
        email: json["data"]["email_address"],
        id: json["data"]["id"],
        profileImage: getImage(json["data"]["profile_picture"])
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "first_name": firstname,
      "last_name": lastname,
      "username": username,
      "email_address": email,
      "password": password,
      "iban": "DE123",
      "profile_picture": profileImage == null ? "" : base64Encode(profileImage.readAsBytesSync()),
    };
  }

  static File getImage(String base64) {

  }

  @override
  String toString() {
    return 'User{username: $username, email: $email, firstname: $firstname, lastname: $lastname, password: $password, profileImage: $profileImage, id: $id}';
  }
}
