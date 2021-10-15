import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/helper/database_service.dart';
import 'package:one_d_m/helper/numeral.dart';
import 'package:one_d_m/models/donation.dart';
import 'package:one_d_m/models/user.dart';
import 'package:one_d_m/provider/statistics_manager.dart';
import 'package:one_d_m/views/users/user_page.dart';
import 'package:provider/provider.dart';

import 'donation_widget.dart';
import 'info_feed.dart';
import 'margin.dart';

class LatestDonatorsView extends StatefulWidget {
  @override
  _LatestDonatorsViewState createState() => _LatestDonatorsViewState();
}

class _LatestDonatorsViewState extends State<LatestDonatorsView> {
  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    return Container(height: 90, child: _buildDonators());
  }

  Widget _buildDonators() => StreamBuilder<List<Donation>>(
        initialData: [],
        stream: DatabaseService.getLatestDonations(limit: 20),
        builder: (_, snapshot) {
          if (!snapshot.hasData) return SizedBox.shrink();
          if (snapshot.hasError) return SizedBox.shrink();

          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(const Duration(seconds: 30), () {
            context.read<StatisticsManager>().refresh();
          });

          List<Donation> d = snapshot.data!;
          if (d.isEmpty) return SizedBox.shrink();

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            separatorBuilder: (context, index) => SizedBox(
              width: 8,
            ),
            itemCount: d.length,
            itemBuilder: (_, index) {
              if (index == 0)
                return Padding(
                  padding: EdgeInsets.only(
                      left: index == 0 ? 12.0 : 0.0,
                      right: index == d.length - 1 ? 12.0 : 0.0),
                  child: Row(
                    children: [
                      Consumer<StatisticsManager>(
                          builder: (context, sm, child) {
                        int _current = sm.home.donationsToday,
                            _goal = sm.home.donationGoalToday;
                        bool dailyTargetDone = _current >= _goal;
                        return Container(
                          height: double.infinity,
                          width: 100,
                          child: Material(
                            color: context.theme.primaryColor,
                            borderRadius:
                                BorderRadius.circular(Constants.radius + 2),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Tagesziel:",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        color: context
                                            .theme.colorScheme.onPrimary),
                                  ),
                                  YMargin(6),
                                  dailyTargetDone
                                      ? Icon(Icons.done,
                                          color: context
                                              .theme.colorScheme.onPrimary)
                                      : DailyGoalWidget(
                                          title:
                                              "${Numeral(_current).value()}/${Numeral(_goal).value()} DV",
                                          percent: _current / _goal,
                                        ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      XMargin(8.0),
                      LatestDonator(d[index]),
                    ],
                  ),
                );
              return Padding(
                padding: EdgeInsets.only(
                    left: index == 0 ? 12.0 : 0.0,
                    right: index == d.length - 1 ? 12.0 : 0.0),
                child: LatestDonator(d[index]),
              );
            },
          );
        },
      );
}

class LatestDonator extends StatelessWidget {
  final Donation donation;
  const LatestDonator(this.donation);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
        future: donation.username != null
            ? Future.value(User(
                id: donation.userId ?? "",
                name: donation.username!,
                imgUrl: donation.userImageUrl,
                blurHash: donation.userBlurHash))
            : Api().users().getOne(donation.userId),
        builder: (context, snapshot) {
          User? u = snapshot.data;

          if (snapshot.hasError) {
            print(donation.userId);
            return SizedBox.shrink();
          }

          return Material(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Constants.radius + 2)),
            child: InkWell(
              onTap: snapshot.hasData
                  ? () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) => UserPage(snapshot.data!)));
                    }
                  : null,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: RoundedAvatar(
                      u?.thumbnailUrl ?? u?.imgUrl,
                      height: 31,
                      loading: !snapshot.hasData,
                      name: u?.name ?? "L",
                    ),
                  ),
                  AutoSizeText(buildAmount(donation),
                      maxLines: 1,
                      minFontSize: 3,
                      overflow: TextOverflow.clip,
                      style: context.theme.textTheme.bodyText1
                          ?.withOpacity(.6)
                          .copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              height: .99)),
                ],
              ),
            ),
          );
        });
  }

  String buildAmount(Donation d) {
    int amount = ((d.amount ?? 1) / (d.donationUnit?.value ?? 1)).round();
    String unit = d.donationUnit?.smiley ??
        (amount == 1 ? d.donationUnit?.singular : d.donationUnit?.name) ??
        'DV';

    return "${Numeral(amount).value()} $unit";
  }
}
