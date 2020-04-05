import 'package:cloud_firestore/cloud_firestore.dart';

class DonationInfo {
  final int dailyAmount,
      dailyAmountTarget,
      monthlyAmount,
      monthlyAmountTarget,
      yearlyAmount,
      yearlyAmountTarget;

  static final String DAILYAMOUNT = "daily_amount",
      DAILYAMOUNTTARGET = "daily_amount_target",
      MONTHLYAMOUNT = "monthly_amount",
      MONTHLYAMOUNTTARGET = "monthly_amount_target",
      YEARLYAMOUNT = "yearly_amount",
      YEARLYAMOUNTTARGET = "yearly_amount_target";

  DonationInfo(
      {this.dailyAmount,
      this.dailyAmountTarget,
      this.monthlyAmount,
      this.monthlyAmountTarget,
      this.yearlyAmount,
      this.yearlyAmountTarget});

  static DonationInfo fromSnapshot(DocumentSnapshot ds) {
    return DonationInfo(
      dailyAmount: ds[DAILYAMOUNT],
      dailyAmountTarget: ds[DAILYAMOUNTTARGET],
      monthlyAmount: ds[MONTHLYAMOUNT],
      monthlyAmountTarget: ds[MONTHLYAMOUNTTARGET],
      yearlyAmount: ds[YEARLYAMOUNT],
      yearlyAmountTarget: ds[YEARLYAMOUNTTARGET],
    );
  }
}
