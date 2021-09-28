import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:one_d_m/models/donation_unit.dart';

class Donation {
  final int amount;
  final bool anonym, useDCs;
  final String id,
      campaignId,
      alternativeCampaignId,
      userId,
      username,
      userImageUrl,
      userBlurHash,
      campaignName,
      campaignImgUrl,
      campaignBlurHash,
      sessionId;
  final DonationUnit donationUnit;
  final DateTime createdAt;

  static final String AMOUNT = "amount",
      ALTERNATIVECAMPAIGNID = "alternative_campaign_id",
      CAMPAIGNID = "campaign_id",
      CAMPAIGNIMGURL = "campaign_image_url",
      CAMPAIGNNAME = "campaign_name",
      USERID = "user_id",
      ISANONYM = "anonym",
      USEDCS = "useDCs",
      SESSION_ID = "session_id",
      CREATEDAT = "created_at",
      CAMPAIGN_DELETED = "campaign_deleted";

  Donation(this.amount,
      {this.id,
      this.campaignId,
      this.alternativeCampaignId,
      this.userId,
      this.campaignName,
      this.campaignImgUrl,
      this.createdAt,
      this.anonym,
      this.useDCs,
      this.sessionId,
      this.campaignBlurHash,
      this.donationUnit,
      this.userBlurHash,
      this.userImageUrl,
      this.username});

  static Donation fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data();
    return Donation(data[AMOUNT],
        campaignId: data[CAMPAIGNID],
        alternativeCampaignId: data[ALTERNATIVECAMPAIGNID],
        userId: data[USERID],
        campaignImgUrl: data[CAMPAIGNIMGURL],
        campaignName: data[CAMPAIGNNAME],
        anonym: data[ISANONYM] ?? false,
        createdAt: (data[CREATEDAT] as Timestamp).toDate(),
        useDCs: data[USEDCS] ?? false,
        sessionId: data[SESSION_ID],
        donationUnit: DonationUnit.fromMap(data),
        userImageUrl: data['image_url'],
        userBlurHash: data['blur_hash'],
        username: data['username']);
  }

  Donation.fromJson(Map<String, dynamic> map)
      : amount = map[AMOUNT],
        id = map['id'],
        campaignId = map[CAMPAIGNID],
        alternativeCampaignId = map[ALTERNATIVECAMPAIGNID],
        userId = map[USERID],
        username = map['username'],
        userImageUrl = map['user_image_url'],
        userBlurHash = map['user_blur_hash'],
        campaignImgUrl = map[CAMPAIGNIMGURL],
        campaignName = map[CAMPAIGNNAME],
        campaignBlurHash = map['campaign_blur_hash'],
        anonym = map[ISANONYM] ?? false,
        createdAt = DateTime.tryParse(map[CREATEDAT]),
        useDCs = map[USEDCS] ?? false,
        sessionId = map[SESSION_ID],
        donationUnit = DonationUnit.fromMap(map);

  static List<Donation> listFromSnapshots(List<DocumentSnapshot> list) {
    return list.map((doc) => fromSnapshot(doc)).toList();
  }

  static List<Donation> listFromJson(List<Map<String, dynamic>> list) {
    return list.map((map) => Donation.fromJson(map)).toList();
  }

  toMap() {
    return {
      AMOUNT: amount,
      ALTERNATIVECAMPAIGNID: alternativeCampaignId,
      CAMPAIGNID: campaignId,
      USERID: userId,
      SESSION_ID: sessionId
    };
  }

  @override
  String toString() {
    return "Amount: ${amount}, Campaign: ${campaignName}, userId: ${userId}, campaignId: ${campaignId}";
  }
}
