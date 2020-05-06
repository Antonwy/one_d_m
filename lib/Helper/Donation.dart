import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:one_d_m/Helper/ImageUrl.dart';

class Donation {
  int amount;
  final String campaignId,
      alternativeCampaignId,
      userId,
      campaignName,
      campaignImgUrl;
  DateTime createdAt;

  static final String AMOUNT = "amount",
      ALTERNATIVECAMPAIGNID = "alternative_campaign_id",
      CAMPAIGNID = "campaign_id",
      CAMPAIGNIMGURL = "campaign_img_url",
      CAMPAIGNNAME = "campaign_name",
      USERID = "user_id",
      CREATEDAT = "created_at";

  Donation(this.amount,
      {this.campaignId,
      this.alternativeCampaignId,
      this.userId,
      this.campaignName,
      this.campaignImgUrl,
      this.createdAt});

  static Donation fromSnapshot(DocumentSnapshot doc) {
    return Donation(doc[AMOUNT],
        campaignId: doc[CAMPAIGNID],
        alternativeCampaignId: doc[ALTERNATIVECAMPAIGNID],
        userId: doc[USERID],
        campaignImgUrl: doc[CAMPAIGNIMGURL],
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
      CAMPAIGNIMGURL: campaignImgUrl,
      USERID: userId,
      CREATEDAT: Timestamp.now()
    };
  }

  @override
  String toString() {
    return "Amount: ${amount}, Campaign: ${campaignName}, userId: ${userId}, campaignId: ${campaignId}";
  }
}
