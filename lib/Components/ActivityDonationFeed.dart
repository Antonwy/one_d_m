import 'package:flutter/material.dart';
import 'package:one_d_m/Components/Avatar.dart';
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
        stream: DatabaseService(um.uid).getDonationFeedStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Donation> donations = snapshot.data;
            if (donations.isEmpty) return Container();
            return Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: Text(
                      "Aktivitäten: ",
                      style: Theme.of(context).textTheme.title,
                    ),
                  ),
                  SizedBox(height: 5),
                  ...donations.map((d) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: DonationWidget(d, withCampaignName: true),
                      ))
                ],
              ),
            );
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
