import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/DonationInfo.dart';

import 'PercentIndicator.dart';

class GeneralDonationFeed extends StatelessWidget {
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
                  "Unsere Ziele:",
                  style: Theme.of(context).textTheme.title,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    PercentIndicator(
                      currentValue: di.dailyAmount,
                      targetValue: di.dailyAmountTarget,
                      color: Colors.indigo,
                      description: "Tagesziel",
                      onTap: () {},
                    ),
                    PercentIndicator(
                      currentValue: di.monthlyAmount,
                      targetValue: di.monthlyAmountTarget,
                      color: Colors.red,
                      description: "Monatsziel",
                      onTap: () {},
                    ),
                    PercentIndicator(
                      currentValue: di.yearlyAmount,
                      targetValue: di.yearlyAmountTarget,
                      color: Colors.orange,
                      description: "Jahresziel",
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }
}
