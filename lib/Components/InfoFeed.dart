import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ink_page_indicator/ink_page_indicator.dart';
import 'package:one_d_m/Helper/AdBalance.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Numeral.dart';
import 'package:one_d_m/Helper/Statistics.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:provider/provider.dart';

class InfoFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 14.0, 10.0, 8),
        child: _ChartsPageView(),
      ),
    );
  }
}

class _ChartsPageView extends StatefulWidget {
  @override
  _ChartsPageViewState createState() => _ChartsPageViewState();
}

class _ChartsPageViewState extends State<_ChartsPageView> {
  PageIndicatorController _pageController = PageIndicatorController();

  @override
  Widget build(BuildContext context) {
    BaseTheme _bTheme = ThemeManager.of(context).colors;
    return Material(
      color: _bTheme.dark,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 228,
        child: StreamBuilder<Statistics>(
            stream: DatabaseService.getStatistics(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
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
                                  value: statistics.campaignCount,
                                  desc: "Projekte",
                                ),
                                _ColumnStats(
                                  value: statistics
                                      .donationStatistics.donationsCount,
                                  desc: "Spenden",
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
                                  desc: "Donation Credits",
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
                      inactiveColor: ColorTheme.white.withOpacity(.3),
                      activeColor: ColorTheme.whiteBlue,
                      inkColor: ColorTheme.whiteBlue,
                      controller: _pageController,
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }
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
              color: _bTheme.contrast,
              fontSize: 50,
              fontWeight: FontWeight.w600),
        ),
        Text(
          desc,
          style: TextStyle(
              color: _bTheme.light, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _DCInformation extends StatelessWidget {
  const _DCInformation({
    Key key,
    @required this.statistics,
  }) : super(key: key);

  final Statistics statistics;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(color: ColorTheme.white),
      child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20.0,
            horizontal: 25.0,
          ),
          child: Column(
            children: [
              StreamBuilder<AdBalance>(
                  stream: DatabaseService.getAdBalance(
                    Provider.of<UserManager>(context).uid,
                  ),
                  builder: (context, snapshot) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${snapshot?.data?.dcBalance ?? 0}',
                                  style: TextStyle(
                                      fontSize: 35.0,
                                      fontWeight: FontWeight.bold,
                                      color: ThemeManager.of(context)
                                          .colors
                                          .contrast),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Donation Credits'),
                                ),
                              ],
                            ),
                            SizedBox(height: 5.0),
                            Text(
                              '${100 - ((snapshot?.data?.activityScore ?? 0) * 100).round()}% bis zum nächsten DC',
                              style: TextStyle(
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                          ],
                        ),
                        _PercentCircle(
                          percent: snapshot?.data?.activityScore ?? 0,
                          radius: 40.0,
                        ),
                      ],
                    );
                  }),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 19.0),
                child: Divider(
                  color: ColorTheme.white.withOpacity(0.1),
                  thickness: 2.0,
                  height: 2.0,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _GoalWidget(
                      title: 'Tagesziel',
                      percent: ((statistics?.donationStatistics?.dailyAmount ??
                                  0) /
                              statistics?.donationStatistics?.dailyAmountTarget)
                          .clamp(0.0, 1.0),
                    ),
                  ),
                  Expanded(
                    child: _GoalWidget(
                      title: 'Monatsziel',
                      percent:
                          ((statistics?.donationStatistics?.monthlyAmount ??
                                      0) /
                                  statistics
                                      ?.donationStatistics?.monthlyAmountTarget)
                              .clamp(0.0, 1.0),
                    ),
                  ),
                  Expanded(
                    child: _GoalWidget(
                      title: 'Jahresziel',
                      percent:
                          ((statistics?.donationStatistics?.yearlyAmount ?? 0) /
                                  statistics
                                      ?.donationStatistics?.yearlyAmountTarget)
                              .clamp(0.0, 1.0),
                    ),
                  ),
                ],
              )
            ],
          )),
    );
  }
}

class _GoalWidget extends StatelessWidget {
  const _GoalWidget({
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
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 14.0),
          _PercentLine(percent: percent),
        ],
      ),
    );
  }
}

class _PercentCircle extends StatelessWidget {
  const _PercentCircle({
    Key key,
    @required this.percent,
    this.radius = 40,
  }) : super(key: key);

  final double radius;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2 * radius,
      width: 2 * radius,
      child: CustomPaint(
        painter: _PercentCirclePainter(percent,
            color: ThemeManager.of(context).colors.contrast),
        child: Center(
          child: Text(
            '${((percent * 100) % 100).round().toString()}%',
            style: TextStyle(
              color: ColorTheme.white,
              fontWeight: FontWeight.w700,
              fontSize: 15.0,
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
      ..color = ColorTheme.white.withOpacity(0.05)
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

class _PercentLine extends StatelessWidget {
  const _PercentLine({Key key, @required this.percent, this.height = 6.0})
      : super(key: key);

  final double percent;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _PercentLinePainter(
            percent: percent,
            height: height,
            color: ThemeManager.of(context).colors.contrast),
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
      ..color = ColorTheme.white.withOpacity(0.05)
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
