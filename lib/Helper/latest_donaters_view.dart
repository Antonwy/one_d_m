import 'package:auto_size_text/auto_size_text.dart';
import 'package:one_d_m/Helper/DonationInfo.dart';

import '../Components/InfoFeed.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:one_d_m/Components/CustomOpenContainer.dart';
import 'package:one_d_m/Components/DonationWidget.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/Statistics.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:one_d_m/Pages/UserPage.dart';

import 'DatabaseService.dart';
import 'Donation.dart';
import 'Numeral.dart';
import 'ThemeManager.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(height: 90, child: _buildDonators());
  }

  Widget _buildDonators() => StreamBuilder(
        stream: DatabaseService.getLatestDonations(limit: 20),
        builder: (_, snapshot) {
          if (!snapshot.hasData) return SizedBox.shrink();
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
                      StreamBuilder<Statistics>(
                          stream: DatabaseService.getStatistics(),
                          initialData: Statistics.zero(),
                          builder: (context, snapshot) {
                            DonationInfo info =
                                snapshot.data.donationStatistics;
                            bool dailyTargetDone =
                                info.dailyAmount >= info.dailyAmountTarget;
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
                                                  "${Numeral(info.dailyAmount).value()}/${Numeral(info.dailyAmountTarget).value()} DV",
                                              percent: info.dailyAmount /
                                                  info.dailyAmountTarget,
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                      XMargin(8.0),
                      _buildDonator(
                          amount: d[index].amount, uid: d[index].userId),
                    ],
                  ),
                );
              return Padding(
                padding: EdgeInsets.only(
                    left: index == 0 ? 12.0 : 0.0,
                    right: index == d.length - 1 ? 12.0 : 0.0),
                child: _buildDonator(
                    amount: d[index].amount, uid: d[index].userId),
              );
            },
          );
        },
      );

  Widget _buildDonator({int amount, String uid}) => FutureBuilder<User>(
      future: DatabaseService.getUser(uid),
      builder: (context, snapshot) {
        User u = snapshot.data;
        return CustomOpenContainer(
          openBuilder: (context, close, scrollController) => UserPage(
            u,
            scrollController: scrollController,
          ),
          tappable: u != null,
          closedElevation: 0,
          closedColor: ThemeManager.of(context).colors.contrast.withOpacity(.6),
          closedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.radius + 2)),
          closedBuilder: (context, open) => Column(
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
              AutoSizeText('${Numeral(amount).value()} DV',
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                        fontWeight: FontWeight.w700,
                        color: ThemeManager.of(context)
                            .colors
                            .dark
                            .withOpacity(0.7),
                      )),
            ],
          ),
        );
      });
}
