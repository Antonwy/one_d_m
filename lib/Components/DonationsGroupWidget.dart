import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/AnimatedFutureBuilder.dart';
import 'package:one_d_m/Components/DonationWidget.dart';
import 'package:one_d_m/Components/UserButton.dart';
import 'package:one_d_m/Helper/CampaignsManager.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/DonationsGroup.dart';
import 'package:one_d_m/Helper/Numeral.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Pages/NewCampaignPage.dart';
import 'package:one_d_m/Pages/UserPage.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'CustomOpenContainer.dart';

class DonationsGroupWidget extends StatelessWidget {
  DonationsGroup donationsGroup;

  DonationsGroupWidget(this.donationsGroup);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = [
      AnimatedFutureBuilder<User>(
        future: DatabaseService.getUser(donationsGroup.userId),
        builder: (context, snapshot) {
          User user = snapshot.data;

          return CustomOpenContainer(
            openBuilder: (context, close, scrollController) => UserPage(
              user,
              scrollController: scrollController,
            ),
            tappable: false,
            closedElevation: 0,
            closedColor: ColorTheme.whiteBlue,
            closedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
            closedBuilder: (context, open) => InkWell(
              onTap: open,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: <Widget>[
                    RoundedAvatar(
                      user?.imgUrl,
                      loading: user == null,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "${user?.name ?? "Laden..."}",
                      maxLines: 1,
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
      Divider(
        height: 1,
      )
    ];

    for (DonationCampaignInfo dci in donationsGroup.campaigns) {
      widgetList.add(Consumer<CampaignsManager>(
        builder: (context, cm, child) => CustomOpenContainer(
          openBuilder: (context, close, scrollController) => NewCampaignPage(
            cm.getCampaign(dci.campaignId),
            scrollController: scrollController,
          ),
          closedElevation: 0,
          closedColor: ColorTheme.whiteBlue,
          closedBuilder: (context, open) => InkWell(
            onTap: open,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: RoundedAvatar(dci.campaignImg),
                title: AutoSizeText(
                  dci.campaignName,
                  maxLines: 1,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text("${timeago.format(dci.createdAt)}"),
                trailing: Text(
                  "${Numeral(dci.amount).value()} DC",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Material(
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(12.0),
        color: ColorTheme.whiteBlue,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widgetList,
        ),
      ),
    );
  }
}
