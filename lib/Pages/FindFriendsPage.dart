import 'package:async/async.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/UserButton.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:permission_handler/permission_handler.dart';

class FindFriendsPage extends StatefulWidget {
  @override
  _FindFriendsPageState createState() => _FindFriendsPageState();
}

class _FindFriendsPageState extends State<FindFriendsPage> {
  TextTheme _textTheme;
  List<Contact> _contacts;
  AsyncMemoizer<List<User>> _memoizer = AsyncMemoizer();

  @override
  void initState() {
    
    WidgetsBinding.instance.addPostFrameCallback((d) => _getContacts());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: ColorTheme.avatar,
      appBar: AppBar(
        backgroundColor: ColorTheme.avatar,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Text(
              "Freunde finden",
              style: _textTheme.title.copyWith(color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Text(
              "Wir nutzen die Nummern deines Telefonbuchs und gleichen sie mit unserer Datenbank ab.",
              style: _textTheme.caption.copyWith(color: Colors.white),
            ),
          ),
          SizedBox(
            height: 18,
          ),
          _contacts == null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: RaisedButton(
                    onPressed: _getContacts,
                    child: Text("Freunde finden"),
                  ),
                )
              : Expanded(
                  child: FutureBuilder<List<User>>(
                      future: _memoizer.runOnce(() =>
                          DatabaseService().getUsersFromContacts(_contacts)),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              ));
                        if (snapshot.data.isEmpty)
                          return Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Text(
                                  "Keiner deiner Freunde nutzt die App bis jetzt.",
                                  style: _textTheme.body1
                                      .copyWith(color: Colors.white),
                                ),
                              ));
                        return ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18.0, vertical: 5),
                              child: UserButton(
                                snapshot.data[index].id,
                                user: snapshot.data[index],
                                color: ColorTheme.blue,
                                textStyle: TextStyle(color: Colors.white),
                                elevation: 0,
                              ),
                            );
                          },
                        );
                      }),
                ),
        ],
      ),
    );
  }

  Future<void> _getContacts() async {
    final PermissionStatus permissionStatus = await _getPermission();
    if (permissionStatus != PermissionStatus.granted) {
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(
              "Bitte erteile uns die Berechtigung deine Kontakte zu lesen.")));
      return;
    } else {
      Iterable<Contact> contacts = await ContactsService.getContacts();
      setState(() {
        _contacts = contacts.toList();
      });
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
