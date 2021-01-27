import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/BottomDialog.dart';
import 'package:one_d_m/Components/CustomOpenContainer.dart';
import 'package:one_d_m/Components/DonationWidget.dart';
import 'package:one_d_m/Components/InfoFeed.dart';
import 'package:one_d_m/Components/SettingsDialog.dart';
import 'package:one_d_m/Components/session_post_feed.dart';
import 'package:one_d_m/Helper/CertifiedSessionsList.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/Numeral.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Helper/keep_alive_stream.dart';
import 'package:one_d_m/Helper/latest_donaters_view.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:one_d_m/Helper/recomended_sessions.dart';
import 'package:one_d_m/Helper/speed_scroll_physics.dart';
import 'package:one_d_m/Pages/UserPage.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback onExploreTapped;
  final ScrollController scrollController;

  const ProfilePage({
    Key key,
    this.onExploreTapped,
    this.scrollController,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  GlobalKey<_ProfilePageState> _myKey = GlobalKey();

  ThemeManager _theme;
  List<Session> mySessions = [];
  List<String> mySessionIds = [];

  @override
  void initState() {
    String uid = Provider.of<UserManager>(context, listen: false).uid;

    ///listen events for user followed sessions
    DatabaseService.getCertifiedSessions().listen((event) {
      mySessions.clear();
      event.forEach((element) {
        DatabaseService.userIsInSession(uid, element.id).listen((isExist) {
          if (isExist) {
            mySessions.add(element);
          }
          setState(() {});
        });
      });
    });

    DatabaseService.getSessionPosts().listen((news) {
      mySessionIds.clear();
      news.sort((a, b) => b.createdAt?.compareTo(a.createdAt));

      List<String> sessionsWithPost = [];

      news.forEach((element) {
        sessionsWithPost.add(element.sessionId);
      });

      ///sort and add sessions with post to the begining of the list
      ///
      List<String> sessionIds = sessionsWithPost.toSet().toList();
      DatabaseService.getCertifiedSessions().listen((sessions) {
        List<String> allSessions = [];

        sessions.forEach((element) {
          allSessions.add(element.id);
        });

        ///add sessions that doesn't have posts

        sessionIds = [...sessionIds, ...allSessions];

        List<String> uniqueIds = sessionIds.toSet().toList();
        uniqueIds.forEach((element) {
          DatabaseService.userIsInSession(uid, element).listen((isExist) {
            if (isExist) {
              mySessionIds.add(element);
            }
            setState(() {});
          });
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return Scaffold(
      backgroundColor: ColorTheme.appBg,
      body: CustomScrollView(
        controller: widget.scrollController,
        physics: CustomPageViewScrollPhysics(),
        slivers: <Widget>[
          Consumer<UserManager>(
            builder: (context, um, child) => StreamBuilder<User>(
                initialData: um.user,
                stream: DatabaseService.getUserStream(um.uid),
                builder: (context, snapshot) {
                  User user = snapshot.data;
                  return SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    actions: <Widget>[],
                    bottom: PreferredSize(
                      preferredSize: Size(MediaQuery.of(context).size.width, 0),
                      child: SafeArea(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "Gespendet: ",
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: _theme.colors.dark),
                                      ),
                                      Text(
                                        "${Numeral(user?.donatedAmount ?? 0).value()} DV",
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: _theme.colors.dark),
                                      ),
                                    ],
                                  ),
                                  Expanded(child: SizedBox()),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      Icons.message_rounded,
                                      size: 25,
                                      color: _theme.colors.dark,
                                    ),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      Icons.notifications_none_rounded,
                                      color: _theme.colors.dark,
                                      size: 28,
                                    ),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      Icons.settings_sharp,
                                      color: _theme.colors.dark,
                                      size: 28,
                                    ),
                                    onPressed: () => BottomDialog(context)
                                        .show(SettingsDialog()),
                                  ),
                                  CustomOpenContainer(
                                      openBuilder:
                                          (context, close, controller) =>
                                              UserPage(user,
                                                  scrollController: controller),
                                      closedColor: ColorTheme.appBg,
                                      closedShape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      closedElevation: 0,
                                      closedBuilder: (context, open) =>
                                          Container(
                                            height: 35,
                                            child: RoundedAvatar(
                                              user?.thumbnailUrl ??
                                                  user?.imgUrl,
                                            ),
                                          )),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ),
          const SliverToBoxAdapter(
            child: YMargin(8),
          ),
          InfoFeed(),

          ///build the sessions that follow by user
          // mySessions.isNotEmpty
          //     ? _buildMySessions(mySessions)
          //     : _buildEmptySession(),y
          const SliverToBoxAdapter(
            child: YMargin(12),
          ),
          SliverToBoxAdapter(
            child: LatestDonatorsView(),
          ),
          const SliverToBoxAdapter(
            child: YMargin(12),
          ),
          mySessionIds.isNotEmpty
              ? SessionPostFeed(
                  userSessions: mySessionIds,
                )
              : _buildEmptySession(),
          mySessions.isEmpty
              ? _buildRecomendedSession()
              : SliverToBoxAdapter(
                  child: SizedBox.shrink(),
                ),
          const SliverToBoxAdapter(
            child: const SizedBox(
              height: 120,
            ),
          )
          // _buildPostFeed(),
        ],
      ),
    );
  }

  Widget _buildEmptySession() => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Image.asset(
                "assets/images/img_empty_session.png",
                height: 143,
                width: 206,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Du bist momentan kein Mitglied einer Session.\nDu kannst auf der 'Entdecken' Seite \nInfluencer-Sessions und Projekten folgen.",
                style: _theme.textTheme.dark.bodyText1,
                textAlign: TextAlign.center,
              ),
              const YMargin(12),
              // RaisedButton(
              //   onPressed: widget.onExploreTapped,
              //   child: AutoSizeText(
              //     'Entdecke Sessions',
              //     style: Theme.of(context).accentTextTheme.button,
              //   ),
              //   color: ThemeManager.of(context).colors.dark,
              // ),
            ],
          ),
        ),
      );

  Widget _buildRecomendedSession() => SliverToBoxAdapter(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Text(
                  "Sessions die dich interessieren könnten:",
                  style: _theme.textTheme.dark.bodyText1
                      .copyWith(fontWeight: FontWeight.w700, fontSize: 18),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            const YMargin(12),
            RecomendedSessions(),
          ],
        ),
      );

  Widget _buildSessions(List<BaseSession> sessionsIds) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(
              left: 0.0, top: 10.0, bottom: 10.0, right: 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Text(
                  "Deine Sessions",
                  style: _theme.textTheme.dark.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Helper.hexToColor('#3E313F')),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Container(
                height: 116,
                child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (context, index) => SizedBox(
                          width: 8,
                        ),
                    itemBuilder: (context, index) => Padding(
                        padding: EdgeInsets.only(
                            left: index == 0 ? 12.0 : 0.0,
                            right:
                                index == sessionsIds.length - 1 ? 12.0 : 0.0),
                        child: CertifiedSessionView(sessionsIds[index])),
                    itemCount: sessionsIds.length),
              ),
            ],
          ),
        ),
      );

  Widget _buildSession(String sid) => KeepAliveStreamBuilder(
        stream: DatabaseService.getSession(sid),
        builder: (_, snapshot) {
          if (!snapshot.hasData) return SizedBox.shrink();
          Session s = snapshot.data;
          return CertifiedSessionView(s);
        },
      );
}
