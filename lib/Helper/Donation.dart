import 'package:cloud_firestore/cloud_firestore.dart';

class Donation {
  int amount;
  final String campaignId, alternativeCampaignId, userId, campaignName;
  DateTime createdAt;

  static final String AMOUNT = "amount",
      ALTERNATIVECAMPAIGNID = "alternative_campaign_id",
      CAMPAIGNID = "campaign_id",
      CAMPAIGNNAME = "campaign_name",
      USERID = "user_id",
      CREATEDAT = "created_at";

  Donation(this.amount,
      {this.campaignId,
      this.alternativeCampaignId,
      this.userId,
      this.campaignName,
      this.createdAt});

  static Donation fromSnapshot(DocumentSnapshot doc) {
    return Donation(doc[AMOUNT],
        campaignId: doc[CAMPAIGNID],
        alternativeCampaignId: doc[ALTERNATIVECAMPAIGNID],
        userId: doc[USERID],
        campaignName: doc[CAMPAIGNNAME],
        createdAt: (doc[CREATEDAT] as Timestamp).toDate());
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
      USERID: userId,
      CREATEDAT: Timestamp.now()
    };
  }

  @override
  String toString() {
    // TODO: implement toString
    return "Amount: ${amount}, Campaign: ${campaignName}, userId: ${userId}, campaignId: ${campaignId}";
  }
}
