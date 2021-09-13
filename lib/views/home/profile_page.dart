import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/components/custom_open_container.dart';
import 'package:one_d_m/components/donation_widget.dart';
import 'package:one_d_m/components/info_feed.dart';
import 'package:one_d_m/components/latest_donaters_view.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/components/push_notification.dart';
import 'package:one_d_m/components/replace_text.dart';
import 'package:one_d_m/components/post_feed.dart';
import 'package:one_d_m/components/settings_dialog.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/helper/currency.dart';
import 'package:one_d_m/helper/database_service.dart';
import 'package:one_d_m/helper/numeral.dart';
import 'package:one_d_m/helper/recomended_sessions.dart';
import 'package:one_d_m/helper/speed_scroll_physics.dart';
import 'package:one_d_m/models/ad_balance.dart';
import 'package:one_d_m/models/daily_report.dart';
import 'package:one_d_m/models/feed.dart';
import 'package:one_d_m/models/user.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:one_d_m/views/users/user_page.dart';
import '../../Helper/Helper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'daily_reports_page.dart';
import 'notification_page.dart';

class ProfilePage extends StatefulWidget {
  final ScrollController scrollController;

  const ProfilePage({
    Key key,
    this.scrollController,
  }) : super(key: key);

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.appBg,
      body: CustomScrollView(
        controller: widget.scrollController,
        physics: CustomPageViewScrollPhysics(),
        slivers: <Widget>[
          Consumer<UserManager>(
              builder: (context, um, child) => SliverPersistentHeader(
                    delegate: _ProfileHeader(um.user,
                        safeArea: MediaQuery.of(context).padding.top),
                    pinned: true,
                  )),
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
          PostFeed(),
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

  @override
  bool get wantKeepAlive => true;
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
      builder: (context, snapshot) => (snapshot.data?.gift ?? 0) > 0
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
                          child: ReplaceText(
                        text: snapshot.data.giftMessage,
                        value: snapshot.data.gift.toString(),
                        style: _theme.textTheme.textOnDark.bodyText1,
                      )),
                      XMargin(6),
                      OfflineBuilder(
                        child: Container(),
                        connectivityBuilder: (context, status, child) =>
                            FlatButton.icon(
                          color: _theme.colors.contrast,
                          disabledColor: _theme.colors.contrast.withOpacity(.8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                          onPressed: _loading || _collected
                              ? null
                              : status != ConnectivityResult.none
                                  ? () async {
                                      setState(() {
                                        _loading = true;
                                      });
                                      UserManager um =
                                          context.read<UserManager>();
                                      await DatabaseService.getGift(um.uid,
                                          gift: snapshot.data.gift);
                                      try {
                                        await Api()
                                            .account()
                                            .addDvs(snapshot.data?.gift ?? 1);
                                      } catch (e) {
                                        print(e);
                                      }
                                      await um.reloadUser();

                                      await PushNotification.of(context).show(
                                          NotificationContent(
                                              title:
                                                  "${snapshot.data.gift} DV eingesammelt"));
                                      setState(() {
                                        _loading = false;
                                        _collected = true;
                                      });
                                    }
                                  : () {
                                      Helper.showConnectionPushNotification(
                                          context);
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
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
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
  double _minExtend, _maxExtend, safeArea;
  bool _fullVisible = true;

  _ProfileHeader(this.user, {this.safeArea}) {
    _maxExtend = safeArea + 190;
    _minExtend = safeArea + 64;
  }

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
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
              Stack(
                children: [
                  Opacity(
                      opacity: 1 - percentage,
                      child: IgnorePointer(
                          ignoring: !_fullVisible,
                          child: _ScrolledHeader(
                            showSettings: showSettingsDialog,
                          ))),
                  Opacity(
                      opacity: percentage,
                      child: Transform.translate(
                          offset: Tween<Offset>(
                                  begin: Offset(0, _minExtend - maxExtent),
                                  end: Offset.zero)
                              .transform(percentage),
                          child: IgnorePointer(
                              ignoring: _fullVisible,
                              child: _NotScrolledHeader(
                                showSettings: showSettingsDialog,
                              ))))
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  void showSettingsDialog(BuildContext context) {
    showMaterialModalBottomSheet(
        context: context,
        builder: SettingsDialog.builder,
        backgroundColor: ColorTheme.appBg,
        duration: Duration(milliseconds: 250),
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(Constants.radius))));
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

class AppBarButton extends StatelessWidget {
  const AppBarButton(
      {Key key,
      this.icon,
      this.child,
      this.color,
      this.iconColor,
      this.hint = 0,
      this.elevation = 0,
      this.onPressed,
      this.text})
      : super(key: key);

  final IconData icon;
  final Color color, iconColor;
  final Widget child;
  final void Function() onPressed;
  final int hint;
  final double elevation;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      color: color ?? ColorTheme.appBg,
      borderRadius: BorderRadius.circular(text == null ? Constants.radius : 26),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
          onTap: onPressed,
          child: Padding(
              padding: EdgeInsets.all((child != null ? 0 : 8)),
              child: _buildIcon(context))),
    );
  }

  Widget _buildIcon(BuildContext context) {
    Widget iconChild;

    if (icon == null) {
      iconChild = child;
    } else {
      iconChild = Icon(
        icon,
        size: text == null ? null : 10,
        color: iconColor ?? ThemeManager.of(context).colors.dark,
      );
    }

    Widget iconPart = hint > 0
        ? Stack(clipBehavior: Clip.none, children: [
            iconChild,
            Positioned(
              left: 0,
              top: -5,
              child: Material(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    hint.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 8),
                  ),
                ),
                shape: CircleBorder(),
                color: Colors.red,
              ),
            )
          ])
        : iconChild;

    if (text == null) return iconPart;

    return Text(
      text,
      style: TextStyle(color: iconColor, fontSize: 10),
    );
  }
}

class _ScrolledHeader extends StatelessWidget {
  final Function(BuildContext context) showSettings;

  const _ScrolledHeader({Key key, this.showSettings}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return Material(
        color: ColorTheme.appBg,
        child: SafeArea(
            bottom: false,
            child: Builder(builder: (context) {
              UserManager um = context.watch<UserManager>();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${um.user?.dvBalance ?? 0}',
                              style: TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                  color: _theme.colors.dark),
                            ),
                            const XMargin(5),
                            Text('Donation Votes',
                                style: _theme.textTheme.dark.bodyText1),
                          ],
                        ),
                        SizedBox(height: 5.0),
                        AutoSizeText(
                          'Entspricht ${Currency((um.user?.dvBalance ?? 0) * 5).value()}',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: _theme.colors.dark),
                        ),
                      ],
                    ),
                    AppBarButton(
                      icon: CupertinoIcons.settings_solid,
                      color: _theme.colors.dark,
                      iconColor: _theme.colors.textOnDark,
                      onPressed: () {
                        showSettings(context);
                      },
                    ),
                  ],
                ),
              );
            })));
  }
}

class _NotScrolledHeader extends StatelessWidget {
  final Function(BuildContext context) showSettings;

  const _NotScrolledHeader({
    Key key,
    @required this.showSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    UserManager um = context.watch<UserManager>();
    User user = um.user;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 6, 12, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Gespendet: ",
                      style: TextStyle(fontSize: 15, color: _theme.colors.dark),
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
                    AppBarButton(
                      icon: CupertinoIcons.quote_bubble_fill,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DailyReportPage()));
                      },
                    ),
                    // StreamBuilder<FeedDoc>(
                    //     initialData: FeedDoc.zero(),
                    //     stream: DatabaseService.getUserFeedDoc(um.uid),
                    //     builder: (context, snapshot) {
                    //       return AppBarButton(
                    //         icon: CupertinoIcons.bell_fill,
                    //         hint: snapshot.data?.unseen ?? 1,
                    //         onPressed: () {
                    //           Navigator.push(
                    //               context,
                    //               MaterialPageRoute(
                    //                   builder: (context) =>
                    //                       NotificationPage(snapshot.data)));
                    //         },
                    //       );
                    //     }),
                    AppBarButton(
                      icon: CupertinoIcons.settings_solid,
                      onPressed: () {
                        showSettings(context);
                      },
                    ),
                    XMargin(6),
                    Container(
                      child: CustomOpenContainer(
                        openBuilder: (context, close, controller) =>
                            UserPage(user, scrollController: controller),
                        closedShape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(Constants.radius)),
                        closedElevation: 0,
                        closedColor: ColorTheme.appBg,
                        tappable: user != null,
                        closedBuilder: (context, open) => RoundedAvatar(
                          user?.thumbnailUrl ?? user?.imgUrl,
                          name: user?.name,
                          blurHash: user?.blurHash,
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
    );
  }
}
