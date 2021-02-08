import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/UserButton.dart';
import 'package:one_d_m/Components/UserFollowButton.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:one_d_m/Pages/NewCampaignPage.dart';
import 'package:provider/provider.dart';

import 'BottomDialog.dart';
import 'CustomOpenContainer.dart';
import 'DonationDialogWidget.dart';

class CampaignHeader extends StatelessWidget {
  final Campaign campaign;

  const CampaignHeader({Key key, this.campaign}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ThemeManager _theme = ThemeManager.of(context);

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
        child: CustomOpenContainer(
          closedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.radius)),
          closedElevation: 1,
          openBuilder: (context, close, scrollController) =>
              NewCampaignPage(campaign, scrollController: scrollController),
          closedColor: ColorTheme.appBg,
          closedBuilder: (context, open) => InkWell(
            onTap: open,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                RepaintBoundary(
                  child: CachedNetworkImage(
                    imageUrl: campaign.imgUrl,
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Center(
                        child: Icon(
                      Icons.error,
                      color: ColorTheme.orange,
                    )),
                    alignment: Alignment.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          Expanded(
                            child: AutoSizeText(
                              campaign.name,
                              style: textTheme.headline6,
                              maxLines: 1,
                            ),
                          ),
                          XMargin(12),
                          Material(
                              clipBehavior: Clip.antiAlias,
                              color: _theme.colors.contrast.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                onTap: () async {
                                  await _donate(context, campaign);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 12),
                                  child: Text(
                                    "Unterstützen",
                                    style: _theme.textTheme.dark.bodyText1
                                        .copyWith(
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ))
                        ],
                      ),
                      YMargin(8),
                      campaign.shortDescription == null
                          ? Container()
                          : Text(campaign.shortDescription),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Future<void> _donate(BuildContext context, Campaign campaign) async {
    BottomDialog bd = BottomDialog(context);
    UserManager um = context.read<UserManager>();
    return bd.show(DonationDialogWidget(
      campaign: campaign,
      user: um.user,
      context: context,
      close: bd.close,
      uid: um.uid,
    ));
  }
}
