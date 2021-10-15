import 'package:cloud_firestore/cloud_firestore.dart';

class UserCharge {
  int? amount;
  String? userId;
  bool? error;

  static const String AMOUNT = "amount", USER_ID = "user_id", ERROR = "error";

  UserCharge({this.amount, this.userId, this.error});

  factory UserCharge.fromMap(DocumentSnapshot doc) {
    return UserCharge(
        amount: doc[AMOUNT], userId: doc[USER_ID], error: doc[ERROR] ?? false);
  }
}
