import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/DonationInfo.dart';

import 'PercentIndicator.dart';

class GeneralDonationFeed extends StatelessWidget {
  // PageController _pageController = PageController(viewportFraction: .5);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DonationInfo>(
        stream: DatabaseService().getDonationInfo(),
        builder: (context, snapshot) {
          DonationInfo di = snapshot.data;

          if (!snapshot.hasData)
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Text(
                  "Unsere Ziele",
                  style: Theme.of(context).textTheme.title,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      width: 18,
                    ),
                    PercentIndicator(
                      currentValue: di.dailyAmount,
                      targetValue: di.dailyAmountTarget,
                      description: "Heute",
                      onTap: () {},
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    PercentIndicator(
                      currentValue: di.monthlyAmount,
                      targetValue: di.monthlyAmountTarget,
                      description: "Monat",
                      onTap: () {},
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    PercentIndicator(
                      currentValue: di.yearlyAmount,
                      targetValue: di.yearlyAmountTarget,
                      description: "Jahr",
                      onTap: () {},
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }
}
