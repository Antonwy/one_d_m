import 'dart:collection';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/components/users/user_button.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/contact_manager.dart';
import 'package:one_d_m/helper/database_service.dart';
import 'package:one_d_m/models/contacts.dart';
import 'package:one_d_m/models/user.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:one_d_m/views/home/home_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

class FindFriendsPage extends StatefulWidget {
  bool afterRegister;
  ScrollController? scrollController;

  FindFriendsPage({this.afterRegister = false, this.scrollController});

  @override
  _FindFriendsPageState createState() => _FindFriendsPageState();
}

class _FindFriendsPageState extends State<FindFriendsPage> {
  late TextTheme _textTheme;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    context
        .read<FirebaseAnalytics>()
        .setCurrentScreen(screenName: "Find Friends Page");
  }

  Future<Contacts?> getContacts() async {
    ContactManager cm = ContactManager();
    if (!(await cm.hasPermission())) {
      PermissionStatus status = await cm.getPermission();
      if (status != PermissionStatus.granted)
        return Api().contacts().uploadContacts([]);
    }

    List<String> contacts = await cm.phoneNumberList();
    return Api().contacts().uploadContacts(contacts);
  }

  Stream<Contacts?> contactsStream() async* {
    if (Api.box == null) await Api().init();
    if (Api.box != null && Api.box!.containsKey("contacts")) {
      Map res = await Api.box!.get("contacts");

      Json castedMap = Json.from(res);
      yield Contacts.fromJson(castedMap);
    }

    yield await getContacts();
  }

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;
    ThemeData _theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: widget.afterRegister
          ? Consumer<UserManager>(
              builder: (context, um, child) => FloatingActionButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                      (route) => route.isCurrent);
                },
                child: Icon(
                  Icons.arrow_forward,
                ),
              ),
            )
          : null,
      body: CustomScrollView(controller: widget.scrollController, slivers: <
          Widget>[
        SliverAppBar(
            title: widget.afterRegister
                ? Text(
                    "Finde Freunde",
                  )
                : null,
            elevation: 0,
            backgroundColor: _theme.backgroundColor,
            iconTheme: IconThemeData(color: _theme.primaryColor),
            automaticallyImplyLeading: !widget.afterRegister,
            centerTitle: false),
        StreamBuilder<Contacts?>(
            stream: contactsStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return SliverFillRemaining(
                    child: Center(
                        child: LoadingIndicator(
                  message: "Lade Nutzer...",
                )));

              List<User> usersFromContacts =
                  snapshot.data?.usersFromContacts ?? [];
              List<User> topUsers = snapshot.data?.topUsers ?? [];

              return MultiSliver(
                children: [
                  if (usersFromContacts.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                            child: Text("Nutzer aus deinen Kontakten",
                                style: _textTheme.headline5!),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                                "Diese Freunde nutzen ebenfalls die App! Abonniere sie doch direkt, um updates von ihnen zu bekommen!",
                                style: _textTheme.caption!.withOpacity(.5)),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  if (usersFromContacts.isNotEmpty)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 5),
                                child: UserButton(
                                  usersFromContacts[index].id,
                                  user: usersFromContacts[index],
                                  withAddButton: true,
                                  elevation: 1,
                                ),
                              ),
                          childCount: usersFromContacts.length),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 20),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text("Beliebte Nutzer",
                                style: _textTheme.headline5!),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                                "Diese Nutzer gehören zu den beliebtesten Nutzern auf unserer Platform!",
                                style: _textTheme.caption!.withOpacity(.5)),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 20),
                    sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 5),
                        child: UserButton(
                          topUsers[index].id,
                          user: topUsers[index],
                          withAddButton: true,
                          elevation: 1,
                        ),
                      ),
                      childCount: topUsers.length,
                    )),
                  )
                ],
              );
            }),
        widget.afterRegister
            ? SliverToBoxAdapter(
                child: SizedBox(
                  height: 80,
                ),
              )
            : SliverToBoxAdapter(),
      ]),
    );
  }
}
