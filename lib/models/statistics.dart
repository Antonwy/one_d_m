class Statistics {
  static const String USERCOUNT = "user_count",
      USERINFO = "users_info",
      CAMPAIGNCOUNT = "campaign_count",
      CAMPAIGNINFO = "campaigns_info";
  final int userCount,
      donationCount,
      donationAmountCount,
      campaignCount,
      sessionCount,
      donationsToday,
      donationGoalToday;

  Statistics(
      {required this.userCount,
      required this.campaignCount,
      required this.donationCount,
      required this.donationAmountCount,
      required this.sessionCount,
      required this.donationsToday,
      required this.donationGoalToday});

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
