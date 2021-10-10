import 'package:one_d_m/models/donation.dart';

class SessionDonation {
  final int? amount;
  final String? userId, userBlurHash, userImageUrl, userThumbnailUrl, username;
  final DateTime? createdAt;

  SessionDonation(
      {this.amount,
      this.userId,
      this.userBlurHash,
      this.userImageUrl,
      this.userThumbnailUrl,
      this.username,
      this.createdAt});

  SessionDonation.fromJson(Map<String, dynamic> map)
      : amount = map[Donation.AMOUNT],
        userId = map[Donation.USERID],
        userBlurHash = map[USER_BLUR_HASH],
        userImageUrl = map[USER_IMAGE_URL],
        userThumbnailUrl = map[USER_THUMBNAIL_URL],
        username = map[USERNAME],
        createdAt = DateTime.tryParse(map[Donation.CREATEDAT]);

  static List<SessionDonation> listFromJson(List<Map<String, dynamic>> list) {
    return list.map((val) => SessionDonation.fromJson(val)).toList();
  }

  static const String USER_BLUR_HASH = "user_blur_hash",
      USER_IMAGE_URL = "user_image_url",
      USERNAME = "username",
      USER_THUMBNAIL_URL = "user_thumbnail_url";
}
