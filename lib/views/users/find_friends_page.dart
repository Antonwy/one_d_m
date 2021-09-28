import 'dart:collection';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/components/user_button.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/contact_manager.dart';
import 'package:one_d_m/helper/database_service.dart';
import 'package:one_d_m/models/user.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:one_d_m/views/home/home_page.dart';
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
    context
        .read<FirebaseAnalytics>()
        .setCurrentScreen(screenName: "Find Friends Page");

    getContacts();
  }

  Future<void> getContacts() async {
    try {
      ContactManager cm = ContactManager();
      if (!(await cm.hasPermission())) {
        PermissionStatus status = await cm.getPermission();
        print(status);
        if (status != PermissionStatus.granted) return;
      }
      print(await cm.phoneNumberList());
    } catch (e) {
      print(e);
    }
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
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                      (route) => route.isCurrent);
                },
                backgroundColor: _theme.colors.dark,
                child: Icon(
                  Icons.arrow_forward,
                  color: _theme.colors.textOnDark,
                ),
              ),
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(controller: widget.scrollController, slivers: <
            Widget>[
          SliverAppBar(
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
}
