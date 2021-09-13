import 'package:cloud_firestore/cloud_firestore.dart';

class DonationInfo {
  final int dailyAmount,
      dailyAmountTarget,
      monthlyAmount,
      monthlyAmountTarget,
      yearlyAmount,
      yearlyAmountTarget,
      donationsCount,
      allDonations;

  static final String DAILYAMOUNT = "daily_amount",
      DAILYAMOUNTTARGET = "daily_amount_target",
      MONTHLYAMOUNT = "monthly_amount",
      MONTHLYAMOUNTTARGET = "monthly_amount_target",
      YEARLYAMOUNT = "yearly_amount",
      YEARLYAMOUNTTARGET = "yearly_amount_target",
      DONATIONSCOUNT = "donations_count",
      ALLDONATIONS = "all_donations";

  DonationInfo(
      {this.dailyAmount,
      this.dailyAmountTarget,
      this.monthlyAmount,
      this.monthlyAmountTarget,
      this.yearlyAmount,
      this.yearlyAmountTarget,
      this.donationsCount,
      this.allDonations});

  static DonationInfo fromSnapshot(DocumentSnapshot ds) {
    return DonationInfo(
        dailyAmount: ds[DAILYAMOUNT],
        dailyAmountTarget: ds[DAILYAMOUNTTARGET],
        monthlyAmount: ds[MONTHLYAMOUNT],
        monthlyAmountTarget: ds[MONTHLYAMOUNTTARGET],
        yearlyAmount: ds[YEARLYAMOUNT],
        yearlyAmountTarget: ds[YEARLYAMOUNTTARGET],
        donationsCount: ds[DONATIONSCOUNT],
        allDonations: ds[ALLDONATIONS]);
  }

  factory DonationInfo.zero() => DonationInfo(
      dailyAmount: 0,
      dailyAmountTarget: 1000,
      monthlyAmount: 0,
      monthlyAmountTarget: 100000,
      yearlyAmount: 0,
      yearlyAmountTarget: 10000000,
      donationsCount: 0,
      allDonations: 0);
}
