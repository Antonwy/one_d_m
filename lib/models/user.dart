import 'package:cloud_firestore/cloud_firestore.dart';

import 'gift.dart';

class User {
  String? email,
      password,
      phoneNumber,
      imgUrl,
      thumbnailUrl,
      blurHash,
      stripeCustomerId,
      deviceToken;

  String id, name;
  int donatedAmount, dvBalance;
  bool admin, ghost;
  final bool? subscribed;
  final Gift gift;

  static const String NAME = "name",
      EMAIL = "email",
      PHONE_NUMBER = "phone_number",
      ADMIN = "admin",
      DONATED_AMOUNT = "donated_amount",
      IMAGE_URL = "image_url",
      BLUR_HASH = "blur_hash",
      THUMBNAIL_URL = "thumbnail_url",
      DEVICE_TOKEN = "device_token",
      STRIPE_CUSTOMER_ID = "stripe_customer_id",
      GHOST = "ghost",
      DV_BALANCE = "dv_balance";

  User(
      {this.email,
      required this.name,
      this.password,
      required this.id,
      this.subscribed,
      this.donatedAmount = 0,
      this.dvBalance = 0,
      this.phoneNumber,
      this.admin = false,
      this.ghost = false,
      this.stripeCustomerId,
      this.deviceToken,
      this.imgUrl,
      this.thumbnailUrl,
      this.blurHash,
      this.gift = const Gift.zero()});

  static User fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return User(
        id: snapshot.id,
        name: data[User.NAME] ?? "No name",
        admin: data[User.ADMIN],
        ghost: data[User.GHOST] ?? false,
        donatedAmount: data[DONATED_AMOUNT],
        imgUrl: data[IMAGE_URL],
        thumbnailUrl:
            data.containsKey(THUMBNAIL_URL) ? snapshot[THUMBNAIL_URL] : null,
        blurHash: data[BLUR_HASH]);
  }

  User.fromJson(Map<String, dynamic> map)
      : admin = map[ADMIN] ?? false,
        ghost = map[GHOST] ?? false,
        blurHash = map[BLUR_HASH],
        imgUrl = map[IMAGE_URL],
        name = map[NAME] ?? "No name",
        subscribed = map['subscribed'] ?? false,
        thumbnailUrl = map[THUMBNAIL_URL],
        dvBalance = map[DV_BALANCE] ?? 0,
        stripeCustomerId = map[STRIPE_CUSTOMER_ID],
        deviceToken = map[DEVICE_TOKEN],
        email = map[EMAIL],
        phoneNumber = map[PHONE_NUMBER],
        id = map['id'],
        donatedAmount = map[DONATED_AMOUNT] ?? 0,
        gift = Gift.fromMap(Map.from(map['gift'] ?? {}));

  static List<User> listFromJson(List<Map<String, dynamic>> list) {
    return list.map((ss) => User.fromJson(ss)).toList();
  }

  static List<User> listFromSnapshots(List<DocumentSnapshot> snapshots) {
    return snapshots.map((ss) => fromSnapshot(ss)).toList();
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      NAME: name,
      EMAIL: email,
      PHONE_NUMBER: phoneNumber,
      IMAGE_URL: imgUrl,
    };
  }

  Map<String, dynamic> userInfoToMap() {
    return {
      "id": id,
      NAME: name,
      IMAGE_URL: imgUrl,
      THUMBNAIL_URL: thumbnailUrl
    };
  }

  Map<String, dynamic> publicDataToMap() {
    return {
      NAME: name,
      ADMIN: false,
      IMAGE_URL: imgUrl,
      DONATED_AMOUNT: 0,
      GHOST: false
    };
  }

  Map<String, dynamic> privateDataToMap() {
    return {
      EMAIL: email,
      PHONE_NUMBER: phoneNumber,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User && other.name == this.name;
  }

  @override
  int get hashCode {
    return name.hashCode;
  }

  @override
  String toString() {
    return 'User(dvBalance: $dvBalance, ghost: $ghost, EMAIL: $EMAIL, PHONE_NUMBER: $PHONE_NUMBER, ADMIN: $ADMIN, DONATED_AMOUNT: $DONATED_AMOUNT, IMAGE_URL: $IMAGE_URL, BLUR_HASH: $BLUR_HASH, THUMBNAIL_URL: $THUMBNAIL_URL, DEVICE_TOKEN: $DEVICE_TOKEN, STRIPE_CUSTOMER_ID: $STRIPE_CUSTOMER_ID, GHOST: $GHOST, DV_BALANCE: $DV_BALANCE)';
  }
}
