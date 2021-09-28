import 'dart:collection';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/services.dart';
import 'package:one_d_m/helper/database_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactManager {
  Future<PermissionStatus> getPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      return permissionStatus[Permission.contacts] ?? PermissionStatus.denied;
    } else {
      return permission;
    }
  }

  Future<bool> hasPermission() async {
    return (await Permission.contacts.status) == PermissionStatus.granted;
  }

  Future<List<String>> phoneNumberList() async {
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

  Future<void> uploadPhoneNumbers(List<String> numbers) async {
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

//   Future<void> _getContacts() async {
//     final PermissionStatus permissionStatus = await _getPermission();
//     if (permissionStatus != PermissionStatus.granted) {
//       _scaffoldKey.currentState.showSnackBar(SnackBar(
//           content: Text(
//               "Bitte erteile uns die Berechtigung deine Kontakte zu lesen.")));
//       return;
//     } else {
//       Iterable<Contact> contacts = await ContactsService.getContacts();

//       Set<String> numbers = HashSet();

//       for (Contact c in contacts) {
//         List<String> contactNumbers =
//             c.phones.map((item) => item.value).toList();
//         numbers.addAll(contactNumbers);
//         List<String> tempContactNumbers = List.of(contactNumbers);

//         for (String number in tempContactNumbers) {
//           if (number.startsWith("+49")) {
//             numbers.add(number.replaceFirst("+49", "0"));
//           } else if (number.startsWith("0")) {
//             numbers.add(number.replaceFirst("0", "+49"));
//           } else {
//             numbers.remove(number);
//           }
//         }
//       }

//       DatabaseService.callFindFriends(numbers.toList());
//     }
//   }
}

class PermissionException implements Exception {
  String message;
  PermissionException(this.message);
}
