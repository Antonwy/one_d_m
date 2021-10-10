import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:one_d_m/models/user.dart';

class SessionMember {
  final String? id, name, imageUrl, thumbnailUrl, blurHash;
  final int? donatedAmount;

  SessionMember(
      {this.id,
      this.name,
      this.imageUrl,
      this.thumbnailUrl,
      this.blurHash,
      this.donatedAmount});

  factory SessionMember.fromDoc(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SessionMember(
        id: data[ID], donatedAmount: data[DONATED_AMOUNT] ?? 0);
  }

  static List<SessionMember> fromQuerySnapshot(QuerySnapshot qs) {
    return qs.docs.map((doc) => SessionMember.fromDoc(doc)).toList();
  }

  factory SessionMember.fromJson(Map<String, dynamic> map) => SessionMember(
      id: map[ID],
      name: map[User.NAME],
      imageUrl: map[User.IMAGE_URL],
      thumbnailUrl: map[User.THUMBNAIL_URL],
      blurHash: map[User.BLUR_HASH],
      donatedAmount: map[DONATED_AMOUNT]);

  static List<SessionMember> listFromJson(List<Map<String, dynamic>> list) {
    return list.map((m) => SessionMember.fromJson(m)).toList();
  }

  static const String ID = "id", DONATED_AMOUNT = "donated_amount";
}
