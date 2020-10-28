import 'package:cloud_firestore/cloud_firestore.dart';

class Donation {
  final int amount;
  final bool anonym, useDCs;
  final String campaignId,
      alternativeCampaignId,
      userId,
      campaignName,
      campaignImgUrl,
      sessionId;
  final DateTime createdAt;

  static final String AMOUNT = "amount",
      ALTERNATIVECAMPAIGNID = "alternative_campaign_id",
      CAMPAIGNID = "campaign_id",
      CAMPAIGNIMGURL = "campaign_img_url",
      CAMPAIGNNAME = "campaign_name",
      USERID = "user_id",
      ISANONYM = "anonym",
      USEDCS = "useDCs",
      SESSION_ID = "session_id",
      CREATEDAT = "created_at";

  Donation(this.amount,
      {this.campaignId,
      this.alternativeCampaignId,
      this.userId,
      this.campaignName,
      this.campaignImgUrl,
      this.createdAt,
      this.anonym,
      this.useDCs,
      this.sessionId});

  static Donation fromSnapshot(DocumentSnapshot doc) {
    return Donation(doc[AMOUNT],
        campaignId: doc[CAMPAIGNID],
        alternativeCampaignId: doc[ALTERNATIVECAMPAIGNID],
        userId: doc[USERID],
        campaignImgUrl: doc[CAMPAIGNIMGURL],
        campaignName: doc[CAMPAIGNNAME],
        anonym: doc[ISANONYM] ?? false,
        createdAt: (doc[CREATEDAT] as Timestamp).toDate(),
        useDCs: doc[USEDCS] ?? false,
        sessionId: doc[SESSION_ID]);
  }

  static List<Donation> listFromSnapshots(List<DocumentSnapshot> list) {
    return list.map((doc) => fromSnapshot(doc)).toList();
  }

  toMap() {
    return {
      AMOUNT: amount,
      ALTERNATIVECAMPAIGNID: alternativeCampaignId,
      CAMPAIGNID: campaignId,
      CAMPAIGNNAME: campaignName,
      CAMPAIGNIMGURL: campaignImgUrl,
      USERID: userId,
      CREATEDAT: Timestamp.now(),
      ISANONYM: anonym,
      USEDCS: useDCs,
      SESSION_ID: sessionId
    };
  }

  @override
  String toString() {
    return "Amount: ${amount}, Campaign: ${campaignName}, userId: ${userId}, campaignId: ${campaignId}";
  }
}
