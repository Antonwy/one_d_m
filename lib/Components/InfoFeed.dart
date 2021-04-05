import 'dart:math';
import 'dart:io' show Platform;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ink_page_indicator/ink_page_indicator.dart';
import 'package:intl/intl.dart';
import 'package:one_d_m/Helper/AdBalance.dart';
import 'package:one_d_m/Helper/AdManager.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/Numeral.dart';
import 'package:one_d_m/Helper/RemoteConfigManager.dart';
import 'package:one_d_m/Helper/Statistics.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Helper/currency.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'PushNotification.dart';

class InfoFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: _ChartsPageView(),
    );
  }
}

class _ChartsPageView extends StatefulWidget {
  @override
  _ChartsPageViewState createState() => _ChartsPageViewState();
}

class _ChartsPageViewState extends State<_ChartsPageView>
    with AutomaticKeepAliveClientMixin {
  ValueNotifier<double> _page;
  PageIndicatorController _pageController;

  @override
  void initState() {
    super.initState();
    _page = ValueNotifier<double>(0.0);
    _pageController = PageIndicatorController()
      ..addListener(() {
        _page.value = _pageController.page;
      });
  }

  @override
  Widget build(BuildContext context) {
    BaseTheme _bTheme = ThemeManager.of(context).colors;
    return Material(
      color: _bTheme.contrast,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 120,
        child: StreamBuilder<Statistics>(
            stream: DatabaseService.getStatistics(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(_bTheme.dark),
                  ),
                );
              Statistics statistics = snapshot.data;
              return Column(
                children: <Widget>[
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      children: <Widget>[
                        _DCInformation(
                          statistics: statistics,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                _ColumnStats(
                                  value: statistics.userCount,
                                  desc: "Nutzer",
                                ),
                                _ColumnStats(
                                  value: statistics
                                      .donationStatistics.donationsCount,
                                  desc: "Unterstützungen",
                                ),
                                _ColumnStats(
                                  value: statistics.campaignCount,
                                  desc: "Projekte",
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                _ColumnStats(
                                  value: statistics
                                      .donationStatistics.allDonations,
                                  desc: "Donation Votes",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: InkPageIndicator(
                      gap: 8,
                      padding: 0,
                      shape: IndicatorShape.circle(4),
                      inactiveColor: _bTheme.dark.withOpacity(.25),
                      activeColor: _bTheme.dark,
                      inkColor: _bTheme.dark,
                      pageCount: 3,
                      page: _page,
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _ColumnStats extends StatelessWidget {
  final int value;
  final String desc;

  _ColumnStats({this.value, this.desc});

  @override
  Widget build(BuildContext context) {
    BaseTheme _bTheme = ThemeManager.of(context).colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        AutoSizeText(
          Numeral(value).value(),
          style: TextStyle(
              color: _bTheme.dark, fontSize: 32, fontWeight: FontWeight.w600),
        ),
        Text(
          desc,
          style: TextStyle(
              color: _bTheme.dark, fontSize: 12, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}

class _DCInformation extends StatefulWidget {
  const _DCInformation({
    Key key,
    @required this.statistics,
  }) : super(key: key);

  final Statistics statistics;

  @override
  __DCInformationState createState() => __DCInformationState();
}

class __DCInformationState extends State<_DCInformation>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(color: ThemeManager.of(context).colors.dark),
      child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20.0,
            horizontal: 25.0,
          ),
          child: Builder(builder: (context) {
            AdBalance balance = context.watch<AdBalance>();
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${balance?.dcBalance ?? 0}',
                          style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: ThemeManager.of(context).colors.dark),
                        ),
                        const XMargin(5),
                        Text('Donation Votes'),
                      ],
                    ),
                    SizedBox(height: 5.0),
                    AutoSizeText(
                      'Entspricht ${Currency((balance?.dcBalance ?? 0) * 5).value()}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                PlayButton(
                  size: 60,
                )
              ],
            );
          })),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class PlayButton extends StatefulWidget {
  final double size;
  final bool showLabel;

  const PlayButton({
    Key key,
    this.size,
    this.showLabel,
  }) : super(key: key);
  @override
  _PlayButtonState createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton>
    with SingleTickerProviderStateMixin {
  int _alreadyCollectedCoins = 0, _maxDVs;
  bool _loadingAd = true;
  AnimationController _controller;
  ThemeManager _theme;
  Animation<double> _curvedAnimation;

  @override
  void initState() {
    super.initState();

    _maxDVs = context.read<RemoteConfigManager>().maxDVs;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutSine,
    );

    _controller.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.completed:
          _controller.reverse();
          break;
        case AnimationStatus.dismissed:
          Future.delayed(Duration(seconds: 5)).then((val) {
            if (!done) _controller.forward();
          });
          break;
        default:
      }
    });
    _controller.forward();

    _initStorage();

    _initAds();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initAds() {
    RewardedVideoAd.instance.listener = (RewardedVideoAdEvent event,
        {String rewardType, int rewardAmount}) async {
      if (event == RewardedVideoAdEvent.loaded) {
        if (mounted && _loadingAd) {
          RewardedVideoAd.instance.show();
        }
      } else if (event == RewardedVideoAdEvent.rewarded) {
        print('REWARD');
        _adViewed();
      } else if (event == RewardedVideoAdEvent.closed ||
          event == RewardedVideoAdEvent.completed) {
        _loadAd(show: false);
      }
      setState(() {
        _loadingAd = false;
      });
    };
    _loadAd(show: false).then((value) => print('loadAd() -> $value'));
  }

  Future<bool> _loadAd({bool show: true}) {
    setState(() {
      _loadingAd = show;
    });

    return RewardedVideoAd.instance.load(
      adUnitId: AdManager.rewardedAdUnitId,
    );
  }

  Future<void> _showIfAlreadyAvailable() async {
    try {
      await RewardedVideoAd.instance.show();
    } catch (err) {
      PushNotification.of(context).show(NotificationContent(
          title: "Das hat leider nicht funktioniert.",
          body:
              "Momentan haben wir leider keine Werbung die wir dir zeigen können.",
          icon: Icons.error_outline));
      print("Ad Error: $err");
      setState(() {
        _loadingAd = false;
      });
    }
  }

  void _initStorage() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    DateFormat format = DateFormat.yMd();
    String today = format.format(DateTime.now());
    String _lastTimeResetted =
        _prefs.getString(Constants.LAST_TIME_RESETTED_COINS);

    if (_lastTimeResetted == null) {
      print('_lastTimeResetted was null');
      _lastTimeResetted = today;
      await _prefs.setString(Constants.LAST_TIME_RESETTED_COINS, today);
    }

    print("LastTimeResetted: $_lastTimeResetted");

    if (_lastTimeResetted != today) {
      print('LastTimeResetted != Today => resetting coins');
      await _prefs.setInt(Constants.COllECTED_COINS_KEY, 0);
      await _prefs.setString(Constants.LAST_TIME_RESETTED_COINS, today);
    }

    int _collCoins = _prefs.getInt(Constants.COllECTED_COINS_KEY) ?? 0;
    _alreadyCollectedCoins = _collCoins;
  }

  void _adViewed() async {
    _collectCoin();
    String uid = context.read<UserManager>().uid;
    await DatabaseService.incrementAdBalance(uid);
    PushNotification.of(context)
        .show(NotificationContent(title: "Neuer DV!", body: _pushMsgTitle()));
  }

  bool get done => _alreadyCollectedCoins >= _maxDVs;

  void _collectCoin() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    int collectedCoins = _prefs.getInt(Constants.COllECTED_COINS_KEY) ?? 0;
    print("collect coin: $collectedCoins");
    await _prefs.setInt(Constants.COllECTED_COINS_KEY, ++collectedCoins);
    _alreadyCollectedCoins = collectedCoins;
    print('Already collected coins: $_alreadyCollectedCoins');
  }

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.1).animate(_curvedAnimation),
      child: SlideTransition(
        position: Tween<Offset>(begin: Offset.zero, end: Offset(0, -.08))
            .animate(_curvedAnimation),
        child: Material(
          borderRadius: BorderRadius.circular(Constants.radius),
          clipBehavior: Clip.antiAlias,
          color: _theme.colors.dark,
          elevation: 12,
          child: InkWell(
            onTap: _buttonClick,
            child: AspectRatio(
              aspectRatio: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buttonIcon(),
                    YMargin(4),
                    _buttonText(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _pushMsgTitle() {
    if (done) return "Das wars für heute. Vielen Dank für deine Aktivität!";

    return "Viel Spaß beim Spenden!";
  }

  void _buttonClick() async {
    if (_loadingAd) return;

    if (done) {
      Helper.showAlert(context, "Du hast heute bereits $_maxDVs DVs gesammelt!",
          title: "Das wars für heute!");
      return;
    }

    await _loadAd(show: true);
    await _showIfAlreadyAvailable();
  }

  Widget _buttonText() {
    String text = "DV einsammeln";
    if (done)
      text = "${_maxDVs}DV gesammelt";
    else if (_loadingAd) text = "Ad Laden...";

    return AutoSizeText(text,
        maxLines: 1,
        minFontSize: 4,
        style: TextStyle(fontSize: 6, color: _theme.colors.textOnDark));
  }

  Widget _buttonIcon() {
    if (done)
      return Icon(
        Icons.done_rounded,
        color: _theme.colors.textOnDark,
      );

    if (_loadingAd)
      return Container(
        width: 15,
        height: 15,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation(
            _theme.colors.textOnDark,
          ),
        ),
      );

    return Icon(
      CupertinoIcons.play,
      color: _theme.colors.textOnDark,
    );
  }
}

class DailyGoalWidget extends StatelessWidget {
  const DailyGoalWidget({
    Key key,
    @required this.title,
    @required this.percent,
  }) : super(key: key);

  final String title;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AutoSizeText(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            maxLines: 1,
          ),
          YMargin(6),
          PercentLine(percent: percent),
        ],
      ),
    );
  }
}

class PercentCircle extends StatelessWidget {
  const PercentCircle(
      {Key key,
      @required this.percent,
      this.radius = 40,
      this.fontSize = 15,
      this.dark = false})
      : super(key: key);

  final double radius;
  final double percent;
  final double fontSize;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2 * radius,
      width: 2 * radius,
      child: CustomPaint(
        painter: _PercentCirclePainter(percent,
            color: dark
                ? ThemeManager.of(context).colors.dark
                : ThemeManager.of(context).colors.contrast),
        child: Center(
          child: Text(
            '${((percent * 100) % 100).round().toString()}%',
            style: TextStyle(
              color: dark ? ColorTheme.blue : ColorTheme.white,
              fontWeight: FontWeight.w700,
              fontSize: fontSize,
            ),
          ),
        ),
      ),
    );
  }
}

class _PercentCirclePainter extends CustomPainter {
  _PercentCirclePainter(this.percent, {this.color = ColorTheme.orange});

  final double percent;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 5;

    final Paint backgroundPaint = Paint()
      ..color = color.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final Paint percentPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      -pi / 2,
      2 * pi,
      false,
      backgroundPaint,
    );

    canvas.drawArc(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      -pi / 2,
      (2 * pi) * percent,
      false,
      percentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PercentLine extends StatelessWidget {
  const PercentLine(
      {Key key, @required this.percent, this.height = 6.0, this.color})
      : super(key: key);

  final double percent, height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _PercentLinePainter(
            percent: percent,
            height: height,
            color: color ?? ThemeManager.of(context).colors.dark),
      ),
    );
  }
}

class _PercentLinePainter extends CustomPainter {
  _PercentLinePainter(
      {@required this.percent, @required this.height, this.color});

  final double height;
  final double percent;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = height
      ..strokeCap = StrokeCap.round;

    final Paint percentPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = height
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      backgroundPaint,
    );

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset((size.width) * percent, size.height / 2),
      percentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
