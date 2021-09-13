import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/helper/database_service.dart';
import 'package:one_d_m/helper/numeral.dart';
import 'package:one_d_m/models/donation.dart';
import 'package:one_d_m/models/donation_info.dart';
import 'package:one_d_m/models/statistics.dart';
import 'package:one_d_m/models/user.dart';
import 'package:one_d_m/provider/statistics_manager.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/views/users/user_page.dart';
import 'package:provider/provider.dart';

import 'custom_open_container.dart';
import 'donation_widget.dart';
import 'info_feed.dart';
import 'margin.dart';

class LatestDonatorsView extends StatefulWidget {
  @override
  _LatestDonatorsViewState createState() => _LatestDonatorsViewState();
}

class _LatestDonatorsViewState extends State<LatestDonatorsView> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Timer _debounce;

  @override
  Widget build(BuildContext context) {
    return Container(height: 90, child: _buildDonators());
  }

  Widget _buildDonators() => StreamBuilder<List<Donation>>(
        initialData: [],
        stream: DatabaseService.getLatestDonations(limit: 20),
        builder: (_, snapshot) {
          if (!snapshot.hasData) return SizedBox.shrink();

          if (_debounce?.isActive ?? false) _debounce.cancel();
          _debounce = Timer(const Duration(seconds: 30), () {
            print("DEBOUNCE STATISTICS");
            context.read<StatisticsManager>().refresh();
          });

          List<Donation> d = snapshot.data;
          if (d.isEmpty) return SizedBox.shrink();
          return ListView.separated(
            controller: _controller,
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
                            borderRadius:
                                BorderRadius.circular(Constants.radius + 2),
                            color: ThemeManager.of(context)
                                .colors
                                .contrast
                                .withOpacity(.6),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Tagesziel:",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12),
                                  ),
                                  YMargin(6),
                                  dailyTargetDone
                                      ? Icon(Icons.done)
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
                      _buildDonator(d[index]),
                    ],
                  ),
                );
              return Padding(
                padding: EdgeInsets.only(
                    left: index == 0 ? 12.0 : 0.0,
                    right: index == d.length - 1 ? 12.0 : 0.0),
                child: _buildDonator(d[index]),
              );
            },
          );
        },
      );

  Widget _buildDonator(Donation donation) => FutureBuilder<User>(
      future: donation.username != null
          ? Future.value(User(
              id: donation.userId,
              name: donation.username,
              imgUrl: donation.userImageUrl,
              blurHash: donation.userBlurHash))
          : Api().users().getOne(donation.userId),
      builder: (context, snapshot) {
        User u = snapshot.data;
        return Material(
          clipBehavior: Clip.antiAlias,
          color: ThemeManager.of(context).colors.contrast.withOpacity(.6),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.radius + 2)),
          child: InkWell(
            onTap: snapshot.hasData
                ? () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) => UserPage(snapshot.data)));
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
                    name: u?.name,
                  ),
                ),
                AutoSizeText(buildAmount(donation),
                    maxLines: 1,
                    minFontSize: 3,
                    overflow: TextOverflow.clip,
                    style: ThemeManager.of(context)
                        .textTheme
                        .withColor(Colors.grey[700])
                        .bodyText1
                        .copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            height: .99)),
              ],
            ),
          ),
        );
      });

  String buildAmount(Donation d) {
    int amount = (d.amount / (d.donationUnit?.value ?? 1)).round();
    String unit = d.donationUnit?.smiley ??
        (amount == 1 ? d.donationUnit?.singular : d.donationUnit?.name) ??
        'DV';

    return "${Numeral(amount).value()} $unit";
  }
}
