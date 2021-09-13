import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PushNotificationService {
  final FirebaseMessaging _fm = FirebaseMessaging();
  final BuildContext context;

  PushNotificationService(this.context);

  Future<bool> requestPermission() {
    return _fm.requestNotificationPermissions(IosNotificationSettings());
  }

  Future<void> init() {
    _fm.configure(onMessage: (Map<String, dynamic> message) {
      print(message);
    });
  }

  static PushNotificationService of(BuildContext context) =>
      Provider.of<PushNotificationService>(context);
}
