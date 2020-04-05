import 'package:flutter/material.dart';

class NavPageManager extends ChangeNotifier {
  PageController controller;
  double position;

  NavPageManager(PageController controller) {
    this.controller = controller;
    position = controller.offset;
    controller.addListener(_listen);
  }

  void _listen() {
    position = controller.offset;
    notifyListeners();
  }
}
