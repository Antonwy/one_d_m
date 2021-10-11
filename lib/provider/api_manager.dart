import 'package:flutter/material.dart';

class ApiManager extends ChangeNotifier {
  bool apiReachable = true;

  void setApiReachable() {
    if (!apiReachable) {
      apiReachable = true;
      notifyListeners();
    }
  }

  void setApiNotReachable() {
    if (apiReachable) {
      apiReachable = false;
      notifyListeners();
    }
  }
}
