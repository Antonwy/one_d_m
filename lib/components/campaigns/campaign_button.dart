import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/components/donation_widget.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/models/campaign_models/base_campaign.dart';
import 'package:one_d_m/views/campaigns/campaign_page.dart';

import '../custom_open_container.dart';

class CampaignButton extends StatelessWidget {
  final String? id;
  final BaseCampaign? campaign;
  final Color? color;
  final TextStyle? textStyle;
  final double elevation;
  final Function(BaseCampaign?)? onPressed;
  final double borderRadius;

  CampaignButton(this.id,
      {this.campaign,
      this.color,
      this.textStyle = const TextStyle(color: Colors.black),
      this.onPressed,
      this.elevation = 1,
      this.borderRadius = 5});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BaseCampaign?>(
        future: campaign == null
            ? Api().campaigns().getOne(id)
            : Future.value(campaign),
        builder: (context, snapshot) {
          if (snapshot.hasData)
            return CustomOpenContainer(
              openBuilder: (context, open, scrollController) => CampaignPage(
                (snapshot.data!.description == null
                    ? BaseCampaign(
                        id: campaign!.id,
                        imgUrl: campaign!.imgUrl,
                        name: campaign!.name)
                    : snapshot.data)!,
                scrollController: scrollController,
              ),
              closedColor: color ?? ColorTheme.appBg,
              closedElevation: elevation,
              closedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius)),
              closedBuilder: (context, open) => InkWell(
                onTap: () {
                  if (onPressed != null) {
                    onPressed!(snapshot.data);
                    return;
                  }
                  open();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      RoundedAvatar(
                        snapshot.data!.imgUrl ?? '',
                        blurHash: campaign?.blurHash,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: AutoSizeText(
                          "${snapshot.data!.name}",
                          maxLines: 1,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(color: textStyle!.color),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          return Container(height: 20);
        });
  }
}
