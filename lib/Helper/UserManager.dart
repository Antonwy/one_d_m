import 'package:flutter/foundation.dart';
import 'package:one_d_m/Helper/Api.dart';

import 'User.dart';

class UserManager extends ChangeNotifier {
  User user;

  bool hasData = false;

  void setUser([User user]) async {
    if(user != null) this.user = user;
    else user = await Api.getUser();
  
    hasData = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await Api.logout();
    user = null;
    hasData = false;
  }
}
