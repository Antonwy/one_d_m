import 'package:cupertino_tabbar/cupertino_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/DonationInfo.dart';

import 'PercentIndicator.dart';

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
    return StreamBuilder<DonationInfo>(
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
              elevation: 2,
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
        });
  }
}
