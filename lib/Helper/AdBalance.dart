import 'package:cloud_firestore/cloud_firestore.dart';

class AdBalance {
  static const ACTIVITY_SCORE = 'activity_score';
  static const DC_BALANCE = 'dc_balance';

  AdBalance({this.activityScore, this.dcBalance});

  factory AdBalance.fromSnapshot(DocumentSnapshot snapshot) {
    if (snapshot.data == null) return AdBalance(activityScore: 0, dcBalance: 0);
    return AdBalance(
      activityScore: (snapshot.data()[ACTIVITY_SCORE] as num)?.toDouble() ?? 0.0,
      dcBalance: (snapshot.data()[DC_BALANCE] as num)?.toInt(),
    );
  }

  final double activityScore;
  final int dcBalance;
}
