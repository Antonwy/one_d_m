import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/api/stream_result.dart';
import 'package:one_d_m/models/user.dart';
import 'package:one_d_m/models/user_account.dart';
import 'package:provider/provider.dart';

class UserPageManager extends ChangeNotifier {
  User user;
  bool? subscribed = false, isOwnAccount = false;
  late Stream<StreamResult<UserAccount>> userAccountStream;
  UserAccount? userAccount;
  bool loadingMoreInfo = true, fromCache = true;
  final String? uid;

  UserPageManager(this.user, this.uid) {
    initData();
  }

  Future<void> initData() async {
    isOwnAccount = user.id == uid;
    userAccountStream = Api().account().getUserAccountStream(user.id);

    await for (StreamResult<UserAccount> res in userAccountStream) {
      userAccount = res.data;
      user = userAccount!;
      fromCache = res.fromCache;
      subscribed = userAccount!.subscribed;
      loadingMoreInfo = false;
      notifyListeners();
    }
  }

  Future<void> followOrUnfollowUser(bool follow, BuildContext context) async {
    try {
      if (follow)
        await Api().users().subscribe(user.id);
      else
        await Api().users().unsubscribe(user.id);

      await context.read<FirebaseAnalytics>().logEvent(
          name: "${follow ? 'Followed' : 'Unfollowed'} User",
          parameters: {"user": user.id});
    } catch (e) {
      print("something went wrong subscribing user!");
      return;
    }
    subscribed = follow;
    notifyListeners();
  }
}
