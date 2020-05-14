import 'package:flutter/material.dart';
import 'package:ink_page_indicator/ink_page_indicator.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Numeral.dart';
import 'package:one_d_m/Helper/Statistics.dart';

class GeneralDonationFeed extends StatefulWidget {
  // PageController _pageController = PageController(viewportFraction: .5);

  @override
  _GeneralDonationFeedState createState() => _GeneralDonationFeedState();
}

class _GeneralDonationFeedState extends State<GeneralDonationFeed> {
  int _currentPage = 0;
  PageController _pageController = PageController(viewportFraction: .5);

  @override
  Widget build(BuildContext context) {
    return _layout();

    /* return StreamBuilder<DonationInfo>(
        stream: DatabaseService.getDonationInfo(),
        builder: (context, snapshot) {
          DonationInfo di = snapshot.data;

          if (!snapshot.hasData)
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );

          return Padding(
            padding: const EdgeInsets.all(18.0),
            child: Material(
              color: ColorTheme.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
              shadowColor: ColorTheme.red,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    child: Text(
                      "Unsere Ziele",
                      style: Theme.of(context)
                          .textTheme
                          .title
                          .copyWith(color: Colors.white),
                    ),
                  ),
                  Container(
                    height: 130,
                    width: double.infinity,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      children: <Widget>[
                        PercentIndicator(
                          currentValue: di.dailyAmount,
                          targetValue: di.dailyAmountTarget,
                          description: "Täglich",
                          onTap: () {},
                        ),
                        PercentIndicator(
                          currentValue: di.monthlyAmount,
                          targetValue: di.monthlyAmountTarget,
                          description: "Monatlich",
                          onTap: () {},
                        ),
                        PercentIndicator(
                          currentValue: di.yearlyAmount,
                          targetValue: di.yearlyAmountTarget,
                          description: "Jährlich",
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: CupertinoTabBar(
                      Colors.white38,
                      ColorTheme.red,
                      [
                        Text(
                          "Tag",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.75,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Monat",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.75,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Jahr",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.75,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      () => _currentPage,
                      (i) {
                        _pageController.animateToPage(i,
                            duration: Duration(milliseconds: 250),
                            curve: Curves.easeOut);
                      },
                      duration: Duration(milliseconds: 125),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          );
        }); */
  }

  Widget _layout() {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: LineChart(),
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
    return Material(
      color: ColorTheme.blue,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 182,
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
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "Tägliche, monatliche, jährliche Spendenziele",
                                style: TextStyle(
                                    color: Colors.white54,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          Numeral(value).value(),
          style: TextStyle(
              color: ColorTheme.red, fontSize: 50, fontWeight: FontWeight.w600),
        ),
        Text(
          desc,
          style: TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
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
    return Container(
      width: double.infinity,
      height: _height,
      child: Material(
        color: ColorTheme.whiteBlue.withOpacity(.1),
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
                    color: ColorTheme.red,
                  ),
                ),
              ),
              Center(
                  child: Text(
                "${Numeral(currValue).value()}/${Numeral(targetValue).value()}",
                style: TextStyle(
                    color: Colors.white,
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
