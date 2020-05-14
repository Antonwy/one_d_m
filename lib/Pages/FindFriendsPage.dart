import 'dart:collection';

import 'package:async/async.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/UserButton.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Pages/HomePage/HomePage.dart';
import 'package:permission_handler/permission_handler.dart';

class FindFriendsPage extends StatelessWidget {
  bool afterRegister;
  List<String> userIds;

  FindFriendsPage({this.afterRegister = false, this.userIds});

  TextTheme _textTheme;
  AsyncMemoizer<List<User>> _memoizer = AsyncMemoizer();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ColorTheme.avatar,
      appBar: afterRegister
          ? null
          : AppBar(
              brightness: Brightness.dark,
              backgroundColor: ColorTheme.avatar,
              elevation: 0,
            ),
      floatingActionButton: afterRegister
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (c) => HomePage()));
              },
              backgroundColor: ColorTheme.red,
              child: Icon(Icons.arrow_forward),
            )
          : null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Text(
                afterRegister ? "Letzter Schritt!" : "Freunde finden",
                style: _textTheme.headline5.copyWith(color: Colors.white),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Text(
                "Diese Freunde nutzen ebenfalls die App! Abonniere sie doch direkt, um updates von ihnen zu bekommen!",
                style: _textTheme.subtitle2.copyWith(color: Colors.white),
              ),
            ),
            SizedBox(
              height: 18,
            ),
            Expanded(
                child: ListView.builder(
              itemCount: userIds.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18.0, vertical: 5),
                  child: UserButton(
                    userIds[index],
                    color: ColorTheme.blue,
                    textStyle: TextStyle(color: Colors.white),
                    elevation: 0,
                  ),
                );
              },
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _getContacts() async {
    final PermissionStatus permissionStatus = await _getPermission();
    if (permissionStatus != PermissionStatus.granted) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
              "Bitte erteile uns die Berechtigung deine Kontakte zu lesen.")));
      return;
    } else {
      Iterable<Contact> contacts = await ContactsService.getContacts();

      Set<String> numbers = HashSet();

      for (Contact c in contacts) {
        List<String> contactNumbers =
            c.phones.map((item) => item.value).toList();
        numbers.addAll(contactNumbers);
        List<String> tempContactNumbers = List.of(contactNumbers);

        for (String number in tempContactNumbers) {
          if (number.startsWith("+49")) {
            numbers.add(number.replaceFirst("+49", "0"));
          } else if (number.startsWith("0")) {
            numbers.add(number.replaceFirst("0", "+49"));
          } else {
            numbers.remove(number);
          }
        }
      }

      CloudFunctions.instance
          .getHttpsCallable(functionName: "httpFunctions-findFriends")
          .call(numbers.toList());
    }
  }

  Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      return permissionStatus[Permission.contacts] ??
          PermissionStatus.undetermined;
    } else {
      return permission;
    }
  }
}
