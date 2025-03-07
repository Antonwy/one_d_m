import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NavBarManager extends ChangeNotifier {
  late PageController controller;
  double? position = 0.0;

  NavBarManager(PageController controller) {
    this.controller = controller;
    controller.addListener(_listen);
  }

  static NavBarManager of(BuildContext context, {bool listen = true}) {
    return Provider.of<NavBarManager>(context, listen: listen);
  }

  void _listen() {
    position = controller.page;
    notifyListeners();
  }
}
