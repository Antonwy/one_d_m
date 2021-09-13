import 'dart:collection';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactManager {
  static Future<bool> hasPermission() async {
    return (await Permission.contacts.status) == PermissionStatus.granted;
  }

  static Future<List<String>> phoneNumberList() async {
    if (!await hasPermission()) throw PermissionException("Permission denied!");

    Iterable<Contact> contacts = await ContactsService.getContacts();

    Set<String> numbers = HashSet();

    for (Contact c in contacts) {
      List<String> contactNumbers = c.phones.map((item) => item.value).toList();
      numbers.addAll(contactNumbers);
    }

    print("NUMBERSCOUNT: ${numbers.length}");

    return numbers.toList();
  }

  static Future<void> uploadPhoneNumbers(List<String> numbers) async {
    try {
      print("UPLOADING");
      await FirebaseFunctions.instance
          .httpsCallable("httpFunctions-findFriends")
          .call(numbers.toList());
      print("FINISHED");
    } on PlatformException catch (e) {
      print(e);
    }
  }
}

class PermissionException implements Exception {
  String message;
  PermissionException(this.message);
}
