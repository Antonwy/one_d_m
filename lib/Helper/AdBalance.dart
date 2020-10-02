import 'package:cloud_firestore/cloud_firestore.dart';

class AdBalance {
  static const ACTIVITY_SCORE = 'activity_score';
  static const DC_BALANCE = 'dc_balance';

  AdBalance({this.activityScore, this.dcBalance});

  factory AdBalance.fromSnapshot(DocumentSnapshot snapshot) {
    return AdBalance(
      activityScore: (snapshot[ACTIVITY_SCORE] as num)?.toDouble(),
      dcBalance: (snapshot[DC_BALANCE] as num)?.toInt(),
    );
  }

  final double activityScore;
  final int dcBalance;
}