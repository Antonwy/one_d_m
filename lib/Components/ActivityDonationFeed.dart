import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Donation.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:provider/provider.dart';
import 'DonationWidget.dart';

class ActivityDonationFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserManager>(
      builder: (context, um, child) => StreamBuilder<List<Donation>>(
        stream: DatabaseService.getDonationFeedStream(um.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Donation> donations = snapshot.data;

            if (donations.isEmpty)
              return SliverFillRemaining(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 20),
                      Image.asset("assets/images/clip-no-comments.png"),
                      Text(
                          "Keiner deiner Freunde hat bis jetzt etwas gespendet."),
                    ],
                  ),
                ),
              );

            donations.sort((d2, d1) => d1.createdAt.compareTo(d2.createdAt));
            if (donations.isEmpty)
              return SliverFillRemaining(child: Container());
            return SliverPadding(
              padding: EdgeInsets.fromLTRB(18, 10, 18, 100),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
                childAspectRatio: .8,
                children: donations.map((d) => DonationWidget(d)).toList(),
              ),
            );
          }

          return SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()));
        },
      ),
    );
  }
}
