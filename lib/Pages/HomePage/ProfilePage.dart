import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:one_d_m/Components/BottomDialog.dart';
import 'package:one_d_m/Components/CustomOpenContainer.dart';
import 'package:one_d_m/Components/DonationWidget.dart';
import 'package:one_d_m/Components/InfoFeed.dart';
import 'package:one_d_m/Components/PushNotification.dart';
import 'package:one_d_m/Components/SettingsDialog.dart';
import 'package:one_d_m/Components/session_post_feed.dart';
import 'package:one_d_m/Helper/AdBalance.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/DailyReport.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Numeral.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Helper/currency.dart';
import 'package:one_d_m/Helper/latest_donaters_view.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:one_d_m/Helper/recomended_sessions.dart';
import 'package:one_d_m/Helper/speed_scroll_physics.dart';
import 'package:one_d_m/Pages/UserPage.dart';
import 'package:one_d_m/Pages/notification_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../DailyReportPage.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback onExploreTapped;
  final ScrollController scrollController;

  const ProfilePage({
    Key key,
    this.onExploreTapped,
    this.scrollController,
  }) : super(key: key);

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  bool _visible = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
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
                  return SliverPersistentHeader(
                    delegate: _ProfileHeader(user),
                    pinned: true,
                  );
                }),
          ),
          const SliverToBoxAdapter(
            child: YMargin(12),
          ),
          SliverToBoxAdapter(
            child: LatestDonatorsView(),
          ),
          const SliverToBoxAdapter(
            child: _GiftAvailable(),
          ),
          SliverToBoxAdapter(
            child: DailyReportProfileWidget(),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Text("News",
                  style: ThemeManager.of(context).textTheme.dark.headline6),
            ),
          ),
          SliverAnimatedOpacity(
            opacity: _visible ? 1.0 : 0.0,
            duration: Duration(milliseconds: 500),
            sliver: PostFeed(),
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

  toggleVisible() {
    if (_visible) {
      setState(() {
        _visible = false;
      });
    }
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _visible = !_visible;
      });
    });
  }
}

class DailyReportProfileWidget extends StatefulWidget {
  DailyReportProfileWidget();

  @override
  _DailyReportWidgeProfiletState createState() =>
      _DailyReportWidgeProfiletState();
}

class _DailyReportWidgeProfiletState extends State<DailyReportProfileWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DailyReport>(
        stream: DatabaseService.getDailyReport(),
        builder: (context, snapshot) {
          DailyReport dr = snapshot.data;
          print(snapshot);
          if (!snapshot.hasData) return SizedBox.shrink();

          return FutureBuilder<bool>(
              initialData: false,
              future: _shouldShow(),
              builder: (context, snapshot) {
                return !snapshot.data
                    ? SizedBox.shrink()
                    : DailyReportWidget(
                        dailyReport: dr,
                        close: _close,
                      );
              });
        });
  }

  Future<bool> _shouldShow() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String today = DateFormat("dd.MM.yyyy").format(DateTime.now());

    if (_prefs.containsKey(Constants.DAILY_REPORT_KEY)) {
      String val = _prefs.getString(Constants.DAILY_REPORT_KEY);
      if (val == today) return false;
    }

    return true;
  }

  Future<void> _close(String date) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setString(Constants.DAILY_REPORT_KEY, date);
    setState(() {});
  }
}

class DailyReportWidget extends StatelessWidget {
  ThemeManager _theme;
  final DailyReport dailyReport;
  final Future<void> Function(String) close;

  DailyReportWidget({this.dailyReport, this.close});

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 12, 12, 0),
      child: Material(
        color: _theme.colors.contrast,
        borderRadius: BorderRadius.circular(Constants.radius),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AutoSizeText(
                      dailyReport?.title ?? "",
                      style: _theme.textTheme.textOnContrast.headline5,
                      maxLines: 1,
                    ),
                  ),
                  XMargin(6),
                  Text(
                    dailyReport?.date ?? "",
                    style: _theme.textTheme.textOnContrast.caption,
                  )
                ],
              ),
              if (dailyReport?.subtitle == null) YMargin(6),
              Text(
                dailyReport?.subtitle ?? "",
                style: _theme.textTheme.textOnContrast.caption,
              ),
              if (dailyReport?.subtitle != null) YMargin(6),
              Text(
                dailyReport?.text ?? "",
                style: _theme.textTheme.textOnContrast.bodyText2,
              ),
              YMargin(6),
              Text(
                "Was wir gestern erreicht haben:",
                style: _theme.textTheme.textOnContrast.headline6,
              ),
              YMargin(6),
              ..._buildWWR(dailyReport),
              YMargin(12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      dailyReport?.goodbye ?? "",
                      style: _theme.textTheme.textOnContrast.bodyText1,
                    ),
                  ),
                  XMargin(12),
                  close != null
                      ? FlatButton.icon(
                          onPressed: () => close(dailyReport.date),
                          label: Text("Schließen"),
                          icon: Icon(
                            Icons.close,
                            size: 14,
                            color: _theme.colors.textOnDark,
                          ),
                          textColor: _theme.colors.textOnDark,
                          color: _theme.colors.dark,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        )
                      : SizedBox.shrink()
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildWWR(DailyReport dr) {
    List<Widget> widgets = [];

    for (WhatWeReached wwr in (dailyReport?.whatWeReached ?? [])) {
      if (wwr.text.contains("**")) {
        List<String> splitted = wwr.text.split("**");
        widgets.add(RichText(
            text: TextSpan(
                style: _theme.textTheme.textOnContrast.bodyText2,
                children: [
              TextSpan(
                text: splitted[0],
              ),
              TextSpan(
                  text: wwr.value.toString(),
                  style: TextStyle(fontWeight: FontWeight.w800)),
              TextSpan(
                text: splitted.length >= 2 ? splitted[1] : "",
              ),
            ])));
      } else {
        widgets.add(Text(
          wwr.text,
          style: _theme.textTheme.textOnContrast.bodyText1,
        ));
      }
    }

    return widgets;
  }
}

class _GiftAvailable extends StatefulWidget {
  const _GiftAvailable();

  @override
  __GiftAvailableState createState() => __GiftAvailableState();
}

class __GiftAvailableState extends State<_GiftAvailable> {
  bool _loading = false;
  bool _collected = false;

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return StreamBuilder<AdBalance>(
      initialData: AdBalance.zero(),
      stream: DatabaseService.getAdBalance(context.read<UserManager>().uid),
      builder: (context, snapshot) => snapshot.data.gift > 0
          ? Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Constants.radius)),
                margin: EdgeInsets.zero,
                color: _theme.colors.dark,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: AutoSizeText(
                          "Du hast ${snapshot.data.gift} DV bekommen!",
                          style: _theme.textTheme.textOnDark.bodyText1,
                        ),
                      ),
                      FlatButton.icon(
                        color: _theme.colors.contrast,
                        disabledColor: _theme.colors.contrast.withOpacity(.8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                        onPressed: _loading || _collected
                            ? null
                            : () async {
                                setState(() {
                                  _loading = true;
                                });
                                await DatabaseService.getGift(
                                    context.read<UserManager>().uid,
                                    gift: snapshot.data.gift);
                                setState(() {
                                  _loading = false;
                                  _collected = true;
                                });
                                await PushNotification.of(context).show(
                                    NotificationContent(
                                        title:
                                            "${snapshot.data.gift} DV eingesammelt"));
                              },
                        icon: _loading
                            ? Container(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation(
                                      _theme.colors.textOnContrast),
                                ))
                            : Icon(Icons.redeem),
                        label: Text("Einsammeln"),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )
                    ],
                  ),
                ),
              ),
            )
          : SizedBox.shrink(),
    );
  }
}

class NoContentProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                "Sessions die dich interessieren könnten:",
                style: _theme.textTheme.dark.headline6.copyWith(fontSize: 16),
              ),
            ),
          ),
          RecomendedSessions(),
          YMargin(6),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Constants.radius)),
              margin: EdgeInsets.zero,
              color: _theme.colors.dark,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.new_releases, color: _theme.colors.textOnDark),
                    XMargin(12),
                    Expanded(
                      child: Text(
                        "Interessante Projekte und weitere Sessions findest du, wenn du einmal nach rechts swipest.",
                        style: _theme.textTheme.textOnDark.bodyText1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends SliverPersistentHeaderDelegate {
  final User user;
  double _minExtend = 80.0, _maxExtend = 236;
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
          color: ColorTheme.appBg,
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
                                  color: ColorTheme.appBg,
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
                                                    textBaseline:
                                                        TextBaseline.alphabetic,
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
                                              Material(
                                                shape: CircleBorder(),
                                                color: _theme.colors.dark,
                                                child: IconButton(
                                                  icon: Icon(
                                                      CupertinoIcons
                                                          .settings_solid,
                                                      color: _theme
                                                          .colors.textOnDark),
                                                  onPressed: () {
                                                    BottomDialog(context)
                                                        .show(SettingsDialog());
                                                  },
                                                ),
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
                                          // _appBarButton(
                                          //     icon: Icons.message_rounded,
                                          //     onPressed: () {
                                          //       PushNotification.of(context)
                                          //           .show(NotificationContent(
                                          //               title: "Test Titel",
                                          //               body:
                                          //                   "Hier könnte die Beschreibung stehen."));
                                          //     },
                                          //     context: context),
                                          _appBarButton(
                                              icon: CupertinoIcons
                                                  .quote_bubble_fill,
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            DailyReportPage()));
                                              },
                                              context: context),
                                          _appBarButton(
                                              icon: CupertinoIcons.bell_fill,
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            NotificationPage()));
                                              },
                                              context: context),
                                          _appBarButton(
                                              icon:
                                                  CupertinoIcons.settings_solid,
                                              onPressed: () {
                                                BottomDialog(context)
                                                    .show(SettingsDialog());
                                              },
                                              context: context),
                                          XMargin(6),
                                          Container(
                                            child: CustomOpenContainer(
                                              openBuilder: (context, close,
                                                      controller) =>
                                                  UserPage(user,
                                                      scrollController:
                                                          controller),
                                              closedShape:
                                                  RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              Constants
                                                                  .radius)),
                                              closedElevation: 0,
                                              tappable: user != null,
                                              closedBuilder: (context, open) =>
                                                  RoundedAvatar(
                                                user?.thumbnailUrl ??
                                                    user?.imgUrl,
                                                name: user?.name,
                                              ),
                                            ),
                                            width: 40,
                                            height: 40,
                                          ),
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

  Widget _appBarButton(
      {BuildContext context, IconData icon, void Function() onPressed}) {
    return Material(
      color: ColorTheme.appBg,
      borderRadius: BorderRadius.circular(Constants.radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
          onTap: onPressed,
          child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                icon,
                color: ThemeManager.of(context).colors.dark,
              ))),
    );
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
