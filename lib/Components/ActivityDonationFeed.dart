import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/Components/DailyReportFeed.dart';
import 'package:one_d_m/Components/DonationsGroupWidget.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Donation.dart';
import 'package:one_d_m/Helper/DonationsGroup.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:provider/provider.dart';
import 'DonationWidget.dart';

class ActivityDonationFeed extends StatefulWidget {
  @override
  _ActivityDonationFeedState createState() => _ActivityDonationFeedState();
}

class _ActivityDonationFeedState extends State<ActivityDonationFeed> {
  Completer hasData = Completer();

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserManager, DailyReportManager>(
        builder: (context, um, drm, child) {
      return StreamBuilder<List<DonationsGroup>>(
        stream: DatabaseService.getDonationsFeedFromDate(um.uid, drm.date),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 120),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: Column(
                    children: <Widget>[
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(ColorTheme.blue),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Text("Lade Spenden...")
                    ],
                  ),
                ),
              ),
            );
          List<DonationsGroup> donationsGroups = snapshot.data;

          if (donationsGroups.isEmpty)
            return SliverToBoxAdapter(
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 30),
                    SvgPicture.asset(
                      "assets/images/no-donations.svg",
                      height: 200,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Keiner deiner Freunde hat heute etwas gespendet.",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 120,
                    )
                  ],
                ),
              ),
            );

          return SliverList(
              delegate: SliverChildBuilderDelegate(
                  (context, index) => index == donationsGroups.length
                      ? SizedBox(
                          height: 120,
                        )
                      : DonationsGroupWidget(donationsGroups[index]),
                  childCount: donationsGroups.length + 1));
        },
      );
    });

    // return Consumer<UserManager>(
    //   builder: (context, um, child) => StreamBuilder<List<Donation>>(
    //     stream: DatabaseService.getDonationFeedStream(um.uid),
    //     builder: (context, snapshot) {
    //       if (snapshot.hasData) {
    //         List<Donation> donations = snapshot.data;

    // if (donations.isEmpty)
    //   return SliverToBoxAdapter(
    //     child: Align(
    //       alignment: Alignment.topCenter,
    //       child: Column(
    //         children: <Widget>[
    //           SizedBox(height: 30),
    //           SvgPicture.asset(
    //             "assets/images/no-donations.svg",
    //             height: 200,
    //           ),
    //           SizedBox(height: 20),
    //           Text(
    //             "Keiner deiner Freunde hat bis jetzt etwas gespendet.",
    //             style: TextStyle(fontWeight: FontWeight.w500),
    //           ),
    //           SizedBox(
    //             height: 120,
    //           )
    //         ],
    //       ),
    //     ),
    //   );

    //         if (donations.isEmpty)
    //           return SliverFillRemaining(child: Container());
    //         return SliverPadding(
    //           padding: EdgeInsets.fromLTRB(4, 0, 4, 100),
    //           sliver: SliverList(
    //             delegate: SliverChildBuilderDelegate(
    //                 (context, index) => index == 0
    //                     ? Column(
    //                         crossAxisAlignment: CrossAxisAlignment.start,
    //                         children: <Widget>[
    //                           Padding(
    //                             padding: EdgeInsets.symmetric(horizontal: 18),
    //                             child: Text(
    //                               "Spenden ",
    //                               style: Theme.of(context).textTheme.headline6,
    //                             ),
    //                           ),
    //                           Padding(
    //                             padding: EdgeInsets.symmetric(horizontal: 18),
    //                             child: Text(
    //                               "Das haben deine Freunde in letzter Zeit gespendet:",
    //                               style: Theme.of(context).textTheme.caption,
    //                             ),
    //                           ),
    //                           SizedBox(
    //                             height: 4,
    //                           ),
    //                         ],
    //                       )
    //                     : DonationWidget(donations[index - 1]),
    //                 childCount: donations.length + 1),
    //           ),
    //         );
    //       }

    //       return SliverFillRemaining(
    //           child: Center(child: CircularProgressIndicator()));
    //     },
    //   ),
    // );
  }
}
