import 'donation_info.dart';

class Statistics {
  static const String USERCOUNT = "user_count",
      USERINFO = "users_info",
      CAMPAIGNCOUNT = "campaign_count",
      CAMPAIGNINFO = "campaigns_info";
  DonationInfo donationStatistics;
  final int userCount,
      donationCount,
      donationAmountCount,
      campaignCount,
      sessionCount,
      donationsToday,
      donationGoalToday;

  Statistics(
      {this.userCount,
      this.campaignCount,
      this.donationCount,
      this.donationAmountCount,
      this.sessionCount,
      this.donationsToday,
      this.donationGoalToday});

  Statistics.fromJson(Map<String, dynamic> map)
      : userCount = map['user_count'],
        campaignCount = map['campaign_count'],
        donationCount = map['donation_count'],
        donationAmountCount = map['donation_amount_count'],
        sessionCount = map['session_count'],
        donationsToday = map['donations_today'],
        donationGoalToday = map['donation_goal_today'];

  factory Statistics.zero() {
    return Statistics(
        userCount: 0,
        campaignCount: 0,
        donationCount: 0,
        donationAmountCount: 0,
        sessionCount: 0,
        donationsToday: 0,
        donationGoalToday: 100);
  }

  @override
  String toString() {
    return 'Statistics(userCount $userCount, campaignCount $campaignCount, donationCount $donationCount, sessionCount $sessionCount)';
  }
}
