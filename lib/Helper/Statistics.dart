import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/DonationInfo.dart';

class Statistics {
  static const String USERCOUNT = "user_count",
      USERINFO = "users_info",
      CAMPAIGNCOUNT = "campaign_count",
      CAMPAIGNINFO = "campaigns_info";
  DonationInfo donationStatistics;
  int userCount, campaignCount;

  Statistics({this.donationStatistics, this.userCount, this.campaignCount});

  static Statistics fromQuerySnapshot(QuerySnapshot qs) {
    return Statistics(
        donationStatistics: DonationInfo.fromSnapshot(qs.documents
            .where((doc) => doc.documentID == DatabaseService.DONATIONINFO)
            .first),
        userCount: qs.documents
            .where((doc) => doc.documentID == USERINFO)
            .first[USERCOUNT],
        campaignCount: qs.documents
            .where((doc) => doc.documentID == CAMPAIGNINFO)
            .first[CAMPAIGNCOUNT]);
  }
}
