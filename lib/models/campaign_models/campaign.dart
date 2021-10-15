import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:one_d_m/helper/helper.dart';
import 'package:one_d_m/models/donation_unit.dart';
import 'package:one_d_m/models/news.dart';
import 'package:one_d_m/models/organization.dart';
import 'package:one_d_m/models/session_models/base_session.dart';
import 'base_campaign.dart';

class Campaign extends BaseCampaign {
  final bool? subscribed;
  final int memberCount;
  final Organization organization;
  final List<BaseSession> sessions;
  final List<News> news;

  static Campaign fromSnapshot(DocumentSnapshot snapshot) =>
      BaseCampaign.fromSnapshot(snapshot) as Campaign;

  Campaign.fromJson(Map<String, dynamic> map)
      : subscribed = map['subscribed'],
        memberCount = map['member_count'] ?? 0,
        organization = Organization.fromJson(
            Map<String, dynamic>.from(map['organization'])),
        sessions = BaseSession.listFromJson(
            Helper.castJson(map['sessions'] ?? []), DonationUnit.fromMap(map)),
        news = News.listFromJson(Helper.castJson(map['news'] ?? [])),
        super.fromJson(map);

  static List<Campaign> listFromJson(List<Map<String, dynamic>> list) {
    return list.map((map) => Campaign.fromJson(map)).toList();
  }

  static List<Campaign> listFromSnapshot(List<DocumentSnapshot> list) {
    return list.map(Campaign.fromSnapshot).toList();
  }

  @override
  String toString() {
    return 'Campaign{name: $name, description: $description, imgUrl: $imgUrl, endDate: $createdAt, amount: $amount, id: $id, authorId: $authorId, tags: $tags}';
  }
}
