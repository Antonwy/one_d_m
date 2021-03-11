import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:ink_page_indicator/ink_page_indicator.dart';
import 'package:intl/intl.dart';
import 'package:one_d_m/Helper/AdBalance.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/Numeral.dart';
import 'package:one_d_m/Helper/Statistics.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Helper/currency.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:should_rebuild/should_rebuild.dart' as rebuild;

import 'PushNotification.dart';
import 'circular_countdown_timer.dart';

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
  PageIndicatorController _pageController = PageIndicatorController();

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
                      controller: _pageController,
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
        Text(
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
          child: Column(
            children: [
              Builder(builder: (context) {
                AdBalance balance = context.watch<AdBalance>();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              children: [
                                Text(
                                  '${balance?.dcBalance ?? 0}',
                                  style: TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          ThemeManager.of(context).colors.dark),
                                ),
                                const XMargin(5),
                                Text('Donation Votes'),
                              ],
                            ),
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
                    CountDownPointer(
                      size: 60,
                    )
                  ],
                );
              }),
            ],
          )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class CountDownPointer extends StatefulWidget {
  final double size;
  final bool showLabel;

  const CountDownPointer({
    Key key,
    this.size,
    this.showLabel,
  }) : super(key: key);
  @override
  _CountDownPointerState createState() => _CountDownPointerState();
}

class _CountDownPointerState extends State<CountDownPointer>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  CountDownController _countDownController;
  int _collectedDVs = 0;
  int _alreadyCollectedCoins = 0;
  bool _viewAd = false, _loadingAd = true;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _countDownController.pause();
      _saveState();
    } else if (!_viewAd && _alreadyCollectedCoins <= 6)
      _countDownController.resume();
  }

  @override
  void initState() {
    super.initState();

    _initStorage();

    _countDownController = CountDownController();
    WidgetsBinding.instance.addObserver(this);

    _initAds();
  }

  void _initAds() {
    RewardedVideoAd.instance.listener = (RewardedVideoAdEvent event,
        {String rewardType, int rewardAmount}) async {
      if (event == RewardedVideoAdEvent.loaded) {
        if (mounted && _loadingAd) {
          RewardedVideoAd.instance.show();
        }

        setState(() {
          _loadingAd = false;
        });
      } else if (event == RewardedVideoAdEvent.rewarded) {
        print('REWARD');
        _adViewed();
      } else if (event == RewardedVideoAdEvent.closed ||
          event == RewardedVideoAdEvent.completed) {
        _loadAd(show: false);
      }
    };
    _loadAd(show: false).then((value) => print('loadAd() -> $value'));
  }

  Future<bool> _loadAd({bool show: true}) {
    setState(() {
      _loadingAd = show;
    });
    return RewardedVideoAd.instance.load(
      adUnitId: Constants.ADMOB_REWARD_ID,
    );
  }

  Future<void> _showIfAlreadyAvailable() async {
    try {
      await RewardedVideoAd.instance.show();
    } catch (err) {
      print(err);
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
      await _prefs.setDouble(Constants.TIME_REMAINING_KEY, 1.0);
    }

    double _timeRemaining =
        _prefs.getDouble(Constants.TIME_REMAINING_KEY) ?? 1.0;
    print("TimeRemaining: $_timeRemaining");
    _countDownController.restartFromValue(_timeRemaining);
    int _collCoins = _prefs.getInt(Constants.COllECTED_COINS_KEY) ?? 0;
    _alreadyCollectedCoins = _collCoins;

    print('Collected Coins: $_collCoins');

    if (_collCoins > 0) {
      print('INIT COINS: $_collCoins');
      int _modCoins = _collCoins % 2;
      print('MOD COINS: $_modCoins');

      if (_alreadyCollectedCoins >= Constants.DVS_PER_DAY) {
        _collectedDVs = _modCoins;
        _viewAd = true;
        _countDownController.complete();
      } else if (_modCoins == 0 && _timeRemaining == 1.0) {
        _collectedDVs = _modCoins;
        _viewAd = true;
        _countDownController.complete();
      } else {
        setState(() {
          _collectedDVs = _modCoins;
        });
      }
    }
  }

  void _adViewed() {
    _viewAd = false;
    _collectedDVs = 0;
    _countDownController.restart(duration: Constants.USEAGE_POINT_DURATION);
  }

  void _saveState() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setDouble(
        Constants.TIME_REMAINING_KEY, _countDownController.value);
  }

  void _collectCoin() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    int collectedCoins = _prefs.getInt(Constants.COllECTED_COINS_KEY) ?? 0;
    print("collect coin: $collectedCoins");
    await _prefs.setInt(Constants.COllECTED_COINS_KEY, ++collectedCoins);
    _alreadyCollectedCoins++;
    print('Already collected coins: $_alreadyCollectedCoins');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("ViewAd: $_viewAd");
    return CircularCountDownTimer(
      controller: _countDownController,
      duration: Constants.USEAGE_POINT_DURATION,
      width: widget.size,
      height: widget.size,
      showLabel: false,
      color: ThemeManager.of(context).colors.dark.withOpacity(0.05),
      fillColor: ThemeManager.of(context).colors.dark,
      strokeWidth: 5.0,
      strokeCap: StrokeCap.round,
      isTimerTextShown: true,
      isReverse: true,
      textFormat: CountdownTextFormat.MM_SS,
      textStyle: TextStyle(
        color: ColorTheme.blue,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
      childBuilder: () {
        return !_viewAd
            ? Text(
                _countDownController.getTime(),
                style: TextStyle(fontWeight: FontWeight.w600),
              )
            : _timerEnded();
      },
      onComplete: () async {
        print("New DV");
        _collectedDVs++;

        _collectCoin();
        String uid = context.read<UserManager>().uid;
        await DatabaseService.incrementAdBalance(uid);
        PushNotification.of(context).show(
            NotificationContent(title: "Neuer DV!", body: _pushMsgTitle()));

        _viewAd = true;
        _countDownController.complete();
      },
    );
  }

  String _pushMsgTitle() {
    if (_alreadyCollectedCoins >= Constants.DVS_PER_DAY)
      return "Das wars für heute. Vielen Dank für deine Aktivität!";

    return "Viel Spaß beim Spenden!";
  }

  Widget _timerEnded() {
    if (_alreadyCollectedCoins >= Constants.DVS_PER_DAY)
      return IconButton(
          icon: Icon(Icons.done_rounded),
          onPressed: () async {
            Helper.showAlert(context, "Du hast heute bereits 6 DVs gesammelt!",
                title: "Das wars für heute!");
          });

    if (_loadingAd)
      return Container(
        width: 25,
        height: 25,
        child: CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation(ThemeManager.of(context).colors.dark),
        ),
      );

    return IconButton(
        icon: Icon(Icons.play_arrow_rounded),
        onPressed: () async {
          await _loadAd(show: true);
          await _showIfAlreadyAvailable();
          // _adViewed();
        });
  }

  @override
  bool get wantKeepAlive => true;
}

class GoalWidget extends StatelessWidget {
  const GoalWidget({
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
