import 'dart:collection';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/Components/UserButton.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/HomePage/HomePage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class FindFriendsPage extends StatefulWidget {
  bool afterRegister;
  ScrollController scrollController;

  FindFriendsPage({this.afterRegister = false, this.scrollController});

  @override
  _FindFriendsPageState createState() => _FindFriendsPageState();
}

class _FindFriendsPageState extends State<FindFriendsPage> {
  TextTheme _textTheme;

  Stream<List<String>> _contactsStream;
  Future<List<User>> _topRankingUsersFuture;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    precachePicture(
        SvgPicture.asset("assets/images/explore.svg").pictureProvider, null);
    _topRankingUsersFuture = DatabaseService.getUsers(10);
  }

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;
    ThemeManager _theme = ThemeManager.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ColorTheme.appBg,
      floatingActionButton: widget.afterRegister
          ? Consumer<UserManager>(
              builder: (context, um, child) => FloatingActionButton(
                onPressed: () {
                  final homepage = HomePage();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (c) => homepage),
                      (route) => route.isFirst);
                },
                backgroundColor: ColorTheme.orange,
                child: Icon(Icons.arrow_forward),
              ),
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(controller: widget.scrollController, slivers: <
            Widget>[
          SliverAppBar(
            leading: IconButton(
              icon: Icon(
                Icons.keyboard_arrow_down,
                size: 30,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: widget.afterRegister
                ? Text(
                    "Finde Freunde",
                    style: TextStyle(color: ColorTheme.blue),
                  )
                : null,
            brightness: Brightness.dark,
            backgroundColor: ColorTheme.whiteBlue,
            iconTheme: IconThemeData(color: ColorTheme.blue),
            elevation: 0,
            automaticallyImplyLeading: !widget.afterRegister,
          ),
          Consumer<UserManager>(
            builder: (context, um, child) {
              if (_contactsStream == null) {
                _contactsStream = DatabaseService.getFriendsStream(um.uid);
              }
              return StreamBuilder<List<String>>(
                  stream: _contactsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.isNotEmpty) {
                        return SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18.0),
                                child: Text(
                                  "Nutzer aus deinen Kontakten",
                                  style: _textTheme.headline5
                                      .copyWith(color: ColorTheme.blue),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18.0),
                                child: Text(
                                  "Diese Freunde nutzen ebenfalls die App! Abonniere sie doch direkt, um updates von ihnen zu bekommen!",
                                  style: _textTheme.caption.copyWith(
                                      color: ColorTheme.blue.withOpacity(.5)),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              ...snapshot.data.map(
                                (element) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18.0, vertical: 5),
                                  child: UserButton(
                                    element,
                                    withAddButton: true,
                                    color: ColorTheme.appBg,
                                    textStyle:
                                        TextStyle(color: _theme.colors.dark),
                                    elevation: 1,
                                    avatarColor: _theme.colors.dark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return SliverToBoxAdapter();
                      }
                    } else {
                      return SliverPadding(
                        padding: const EdgeInsets.all(18.0),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            children: <Widget>[
                              CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation(ColorTheme.blue),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              AutoSizeText(
                                "Laden...",
                                maxLines: 1,
                                style: TextStyle(color: ColorTheme.blue),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  });
            },
          ),
          FutureBuilder<List<User>>(
              future: _topRankingUsersFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return SliverPadding(
                    padding: const EdgeInsets.all(18.0),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: <Widget>[
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(ColorTheme.blue),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            "Laden...",
                            style: TextStyle(color: ColorTheme.blue),
                          ),
                        ],
                      ),
                    ),
                  );

                if (snapshot.data.isEmpty) return SliverToBoxAdapter();

                return SliverPadding(
                  padding: const EdgeInsets.only(top: 20),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: Text(
                            "Beliebte Nutzer",
                            style: _textTheme.headline5
                                .copyWith(color: ColorTheme.blue),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: Text(
                            "Diese Nutzer gehören zu den beliebtesten Nutzern auf unserer Platform!",
                            style: _textTheme.caption.copyWith(
                                color: ColorTheme.blue.withOpacity(.5)),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                );
              }),
          Consumer<UserManager>(
            builder: (context, um, child) => FutureBuilder<List<User>>(
                future: _topRankingUsersFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return SliverToBoxAdapter();

                  List<User> users = snapshot.data;
                  users.sort(
                      (a, b) => a.donatedAmount.compareTo(b.donatedAmount));
                  users.removeWhere((user) => user.id == um.uid);

                  return SliverPadding(
                    padding: const EdgeInsets.only(bottom: 20),
                    sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18.0, vertical: 5),
                        child: UserButton(
                          users[index].id,
                          user: users[index],
                          withAddButton: true,
                          color: ColorTheme.whiteBlue,
                          textStyle: TextStyle(color: ColorTheme.blue),
                          elevation: 1,
                          avatarColor: ColorTheme.blue,
                        ),
                      ),
                      childCount: users.length,
                    )),
                  );
                }),
          ),
          widget.afterRegister
              ? SliverToBoxAdapter(
                  child: SizedBox(
                    height: 80,
                  ),
                )
              : SliverToBoxAdapter()
        ]),
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

      DatabaseService.callFindFriends(numbers.toList());
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
