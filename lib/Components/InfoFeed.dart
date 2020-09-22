import 'package:flutter/material.dart';
import 'package:ink_page_indicator/ink_page_indicator.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Numeral.dart';
import 'package:one_d_m/Helper/Statistics.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';

class InfoFeed extends StatefulWidget {
  @override
  _InfoFeedState createState() => _InfoFeedState();
}

class _InfoFeedState extends State<InfoFeed> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 14.0, 10.0, 8),
        child: LineChart(),
      ),
    );
  }
}

class LineChart extends StatefulWidget {
  @override
  _LineChartState createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
  PageIndicatorController _pageController = PageIndicatorController();

  @override
  Widget build(BuildContext context) {
    BaseTheme _bTheme = ThemeManager.of(context).theme;
    return Material(
      color: _bTheme.dark,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 177,
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
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Spendenziele",
                                style: TextStyle(
                                    color: _bTheme.light,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Tägliche, monatliche, jährliche Spendenziele",
                                style: TextStyle(
                                    color: _bTheme.light.withOpacity(.54),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Column(
                                children: <Widget>[
                                  _PercentLine(
                                    currValue: statistics
                                        .donationStatistics.dailyAmount,
                                    targetValue: statistics
                                        .donationStatistics.dailyAmountTarget,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  _PercentLine(
                                    currValue: statistics
                                        .donationStatistics.monthlyAmount,
                                    targetValue: statistics
                                        .donationStatistics.monthlyAmountTarget,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  _PercentLine(
                                    currValue: statistics
                                        .donationStatistics.yearlyAmount,
                                    targetValue: statistics
                                        .donationStatistics.yearlyAmountTarget,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                _CollumnStat(
                                  value: statistics.userCount,
                                  desc: "Nutzer",
                                ),
                                _CollumnStat(
                                  value: statistics.campaignCount,
                                  desc: "Projekte",
                                ),
                                _CollumnStat(
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
                                _CollumnStat(
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

class _CollumnStat extends StatelessWidget {
  final int value;
  final String desc;

  _CollumnStat({this.value, this.desc});

  @override
  Widget build(BuildContext context) {
    BaseTheme _bTheme = ThemeManager.of(context).theme;
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

class _PercentLine extends StatelessWidget {
  final double _height = 18;
  int currValue, targetValue;

  _PercentLine({this.currValue, this.targetValue});

  @override
  Widget build(BuildContext context) {
    BaseTheme _bTheme = ThemeManager.of(context).theme;
    return Container(
      width: double.infinity,
      height: _height,
      child: Material(
        color: _bTheme.light.withOpacity(.1),
        borderRadius: BorderRadius.circular(_height / 2),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(builder: (context, constraints) {
          return Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: constraints.maxWidth * (currValue / targetValue),
                  height: _height,
                  child: Material(
                    borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(_height / 2)),
                    color: _bTheme.contrast,
                  ),
                ),
              ),
              Center(
                  child: Text(
                "${Numeral(currValue).value()}/${Numeral(targetValue).value()}",
                style: TextStyle(
                    color: _bTheme.light,
                    fontSize: 10,
                    fontWeight: FontWeight.w700),
              )),
            ],
          );
        }),
      ),
    );
  }
}
