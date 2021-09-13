import 'package:cloud_firestore/cloud_firestore.dart';

class AdBalance {
  static const ACTIVITY_SCORE = 'activity_score';
  static const DC_BALANCE = 'dc_balance';
  static const GIFT = 'gift';
  static const GIFT_MESSAGE = 'gift_message';
  static const DEFAULT_MESSAGE = 'Du hast ** DV bekommen!';

  AdBalance({this.activityScore, this.dcBalance, this.gift, this.giftMessage});

  factory AdBalance.fromSnapshot(DocumentSnapshot snapshot) {
    if (snapshot.data == null || !snapshot.exists) return AdBalance.zero();
    return AdBalance(
      activityScore:
          (snapshot.data()[ACTIVITY_SCORE] as num)?.toDouble() ?? 0.0,
      dcBalance: (snapshot.data()[DC_BALANCE] as num)?.toInt(),
      gift: snapshot.data()[GIFT] ?? 0,
      giftMessage: snapshot.data()[GIFT_MESSAGE] ?? DEFAULT_MESSAGE,
    );
  }

  factory AdBalance.zero() {
    return AdBalance(activityScore: 0, dcBalance: 0, gift: 0);
  }

  final double activityScore;
  final int dcBalance, gift;
  final String giftMessage;
}
