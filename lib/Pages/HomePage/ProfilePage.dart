import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Components/BottomDialog.dart';
import 'package:one_d_m/Components/CustomOpenContainer.dart';
import 'package:one_d_m/Components/DonationWidget.dart';
import 'package:one_d_m/Components/InfoFeed.dart';
import 'package:one_d_m/Components/RoundButtonHomePage.dart';
import 'package:one_d_m/Components/SettingsDialog.dart';
import 'package:one_d_m/Components/session_post_feed.dart';
import 'package:one_d_m/Helper/AdBalance.dart';
import 'package:one_d_m/Helper/CertifiedSessionsList.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/Numeral.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/Statistics.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Helper/currency.dart';
import 'package:one_d_m/Helper/keep_alive_stream.dart';
import 'package:one_d_m/Helper/latest_donaters_view.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:one_d_m/Helper/recomended_sessions.dart';
import 'package:one_d_m/Helper/speed_scroll_physics.dart';
import 'package:one_d_m/Pages/UserPage.dart';
import 'package:provider/provider.dart';

import '../RewardVideoPage.dart';

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
          mySessions.isNotEmpty
              ? SessionPostFeed(
                  userSessions: mySessions,
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
                  style: _theme.textTheme.dark.headline6
                      .copyWith(fontWeight: FontWeight.w600),
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

class _ProfileHeader extends SliverPersistentHeaderDelegate {
  final User user;
  double _minExtend = 80.0, _maxExtend = 336;
  bool _fullVisible = true;

  _ProfileHeader(this.user);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    ThemeManager _theme = ThemeManager.of(context);
    _minExtend = MediaQuery.of(context).padding.top + 64.0;

    return LayoutBuilder(builder: (context, constraints) {
      final double percentage =
          (constraints.maxHeight - _minExtend) / (_maxExtend - minExtent);
      _fullVisible = percentage < 0.5;
      return Container(
        height: constraints.maxHeight,
        child: Material(
          color: Colors.white,
          elevation: Tween<double>(begin: 1.0, end: 0.0).transform(percentage),
          child: Wrap(
            alignment: WrapAlignment.center,
            runSpacing: 0,
            children: [
              StreamProvider<AdBalance>(
                create: (context) => DatabaseService.getAdBalance(
                    context.read<UserManager>().uid),
                builder: (context, child) => Stack(
                  children: [
                    Opacity(
                        opacity: 1 - percentage,
                        child: IgnorePointer(
                          ignoring: !_fullVisible,
                          child: Container(
                              height: constraints.maxHeight,
                              width: constraints.maxWidth,
                              child: Material(
                                  color: _theme.colors.light,
                                  child: SafeArea(
                                      bottom: false,
                                      child: Builder(builder: (context) {
                                        AdBalance balance =
                                            context.watch<AdBalance>();
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .baseline,
                                                    children: [
                                                      Text(
                                                        '${balance?.dcBalance ?? 0}',
                                                        style: TextStyle(
                                                            fontSize: 24.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: _theme
                                                                .colors.dark),
                                                      ),
                                                      const XMargin(5),
                                                      Text('Donation Votes',
                                                          style: _theme
                                                              .textTheme
                                                              .dark
                                                              .bodyText1),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5.0),
                                                  AutoSizeText(
                                                    'Entspricht ${Currency((balance?.dcBalance ?? 0) * 5).value()}',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color:
                                                            _theme.colors.dark),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  PercentCircle(
                                                    percent: balance
                                                            ?.activityScore ??
                                                        0,
                                                    radius: 25.0,
                                                    fontSize: 12,
                                                    dark: true,
                                                  ),
                                                  XMargin(8),
                                                  RoundButtonHomePage(
                                                    dark: true,
                                                    icon: Icons.settings,
                                                    onTap: () {
                                                      BottomDialog(context)
                                                          .show(
                                                              SettingsDialog());
                                                    },
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        );
                                      })))),
                        )),
                    Opacity(
                      opacity: percentage,
                      child: Transform.translate(
                        offset: Tween<Offset>(
                                begin: Offset(0, _minExtend - maxExtent),
                                end: Offset.zero)
                            .transform(percentage),
                        child: IgnorePointer(
                          ignoring: _fullVisible,
                          child: SafeArea(
                            bottom: false,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(12, 6, 12, 0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            "Willkommen,",
                                            style: _theme.materialTheme
                                                .textTheme.headline5
                                                .copyWith(
                                                    fontSize: 32,
                                                    color: _theme.colors.dark),
                                          ),
                                          Text(
                                            "${user?.name}",
                                            style: _theme.materialTheme
                                                .textTheme.headline5
                                                .copyWith(
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.bold,
                                                    color: _theme.colors.dark),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        child: CustomOpenContainer(
                                          openBuilder: (context, close,
                                                  controller) =>
                                              UserPage(user,
                                                  scrollController: controller),
                                          closedShape: CircleBorder(),
                                          closedElevation: 0,
                                          closedBuilder: (context, open) =>
                                              Avatar(
                                            user?.thumbnailUrl ?? user?.imgUrl,
                                            onTap: open,
                                          ),
                                        ),
                                        width: 60,
                                        height: 60,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                      Row(
                                        children: <Widget>[
                                          CustomOpenContainer(
                                            openBuilder:
                                                (context, close, controller) =>
                                                    RewardVideoPage(),
                                            closedShape: CircleBorder(),
                                            closedElevation: 0,
                                            closedColor: _theme.colors.contrast,
                                            closedBuilder: (context, open) =>
                                                RoundButtonHomePage(
                                              icon: Icons.play_arrow_rounded,
                                              onTap: open,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          RoundButtonHomePage(
                                            icon: Icons.settings,
                                            onTap: () {
                                              BottomDialog(context)
                                                  .show(SettingsDialog());
                                            },
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  InfoFeed(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  @override
  double get maxExtent => _maxExtend;

  @override
  double get minExtent => _minExtend;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
