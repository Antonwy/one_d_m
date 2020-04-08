import 'package:flutter/material.dart';

class NavPageManager extends ChangeNotifier {
  PageController controller;
  double position = 1.0;

  NavPageManager(PageController controller) {
    this.controller = controller;
    controller.addListener(_listen);
  }

  void _listen() {
    position = controller.page;
    notifyListeners();
  }
}
