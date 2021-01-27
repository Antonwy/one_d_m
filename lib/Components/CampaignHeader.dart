import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Pages/NewCampaignPage.dart';

import 'CustomOpenContainer.dart';

class CampaignHeader extends StatelessWidget {
  final Campaign campaign;

  const CampaignHeader({Key key, this.campaign}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

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
                      Text(
                        campaign.name,
                        style: textTheme.headline6,
                      ),
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
}
