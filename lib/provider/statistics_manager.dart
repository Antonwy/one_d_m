import 'package:flutter/material.dart';
import 'package:one_d_m/api/api.dart';

import 'package:one_d_m/models/statistics.dart';

class StatisticsManager extends ChangeNotifier {
  Statistics? home;

  StatisticsManager() {
    home = Statistics.zero();
    refresh();
  }

  Future<void> refresh() async {
    try {
      home = await Api().statistics().home();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}
