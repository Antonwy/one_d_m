import 'package:flutter/foundation.dart';
import 'package:one_d_m/Helper/API/Api.dart';
import 'User.dart';

class UserManager extends ChangeNotifier {
  User user;
  bool hasData = false;

  void setUser(User user) {
    this.user = user;
    hasData = true;
  }

  Future<void> logout() async {
    await Api.logout();
    user = null;
    hasData = false;
  }
}
