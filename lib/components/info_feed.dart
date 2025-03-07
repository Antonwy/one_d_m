import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ink_page_indicator/ink_page_indicator.dart';
import 'package:one_d_m/components/play_button.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:one_d_m/helper/ad_manager.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/currency.dart';
import 'package:one_d_m/helper/numeral.dart';
import 'package:one_d_m/models/statistics.dart';
import 'package:one_d_m/provider/statistics_manager.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:provider/provider.dart';

import 'margin.dart';

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

class _ChartsPageViewState extends State<_ChartsPageView> {
  late ValueNotifier<double> _page;
  late PageIndicatorController _pageController;

  @override
  void initState() {
    super.initState();
    _page = ValueNotifier<double>(0.0);
    _pageController = PageIndicatorController()
      ..addListener(() {
        _page.value = _pageController.page ?? 0.0;
      });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    return Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Container(
        height: 120,
        child: Consumer<StatisticsManager>(builder: (context, sm, child) {
          Statistics statistics = sm.home;
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
                              value: statistics.donationCount,
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
                              value: statistics.donationAmountCount,
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
                  shape: IndicatorShape.circle(3),
                  pageCount: 3,
                  page: _page,
                  inactiveColor:
                      _theme.colorScheme.onBackground.withOpacity(.1),
                  activeColor: _theme.colorScheme.onBackground,
                  inkColor: _theme.colorScheme.onBackground,
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
  final int? value;
  final String? desc;

  _ColumnStats({this.value, this.desc});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        AutoSizeText(
          Numeral(value!).value(),
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
        ),
        Text(
          desc!,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}

class _DCInformation extends StatefulWidget {
  const _DCInformation({
    Key? key,
    required this.statistics,
  }) : super(key: key);

  final Statistics statistics;

  @override
  __DCInformationState createState() => __DCInformationState();
}

class __DCInformationState extends State<_DCInformation> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 25.0,
        ),
        child: Builder(builder: (context) {
          UserManager um = context.watch<UserManager>();
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
                        '${um.user?.dvBalance ?? 0}',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const XMargin(5),
                      Text('Donation Votes'),
                    ],
                  ),
                  SizedBox(height: 5.0),
                  AutoSizeText(
                    'Entspricht ${Currency((um.user?.dvBalance ?? 0) * 5).value()}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              ChangeNotifierProvider(
                  create: (context) => AdManagerNotifier(context),
                  builder: (context, child) {
                    return PlayButton(
                      size: 60,
                    );
                  })
            ],
          );
        }));
  }
}

class DailyGoalWidget extends StatelessWidget {
  const DailyGoalWidget({
    Key? key,
    required this.title,
    required this.percent,
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
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: context.theme.colorScheme.onPrimary),
            maxLines: 1,
          ),
          YMargin(6),
          PercentLine(
              percent: percent, color: context.theme.colorScheme.onPrimary),
        ],
      ),
    );
  }
}

class PercentCircle extends StatelessWidget {
  const PercentCircle(
      {Key? key,
      required this.percent,
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
  final Color? color;

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 5;

    final Paint backgroundPaint = Paint()
      ..color = color!.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final Paint percentPaint = Paint()
      ..color = color!
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
      {Key? key, required this.percent, this.height = 6.0, this.color})
      : super(key: key);

  final double percent, height;
  final Color? color;

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
      {required this.percent, required this.height, this.color});

  final double height;
  final double percent;
  final Color? color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()
      ..color = color!.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = height
      ..strokeCap = StrokeCap.round;

    final Paint percentPaint = Paint()
      ..color = color!
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
