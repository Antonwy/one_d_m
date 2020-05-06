import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Pages/NewCampaignPage.dart';

import 'AnimatedFutureBuilder.dart';
import 'CustomOpenContainer.dart';

class CampaignButton extends StatelessWidget {
  String id;
  Campaign campaign;
  Color color;
  TextStyle textStyle;
  double elevation;
  Function(Campaign) onPressed;

  CampaignButton(this.id,
      {this.campaign,
      this.color = Colors.white,
      this.textStyle = const TextStyle(color: Colors.black),
      this.onPressed,
      this.elevation = 1});

  @override
  Widget build(BuildContext context) {
    return AnimatedFutureBuilder<Campaign>(
        future: campaign == null
            ? DatabaseService.getCampaign(id)
            : Future.value(campaign),
        builder: (context, snapshot) {
          if (snapshot.hasData)
            return CustomOpenContainer(
              openBuilder: (context, open, scrollController) => NewCampaignPage(
                snapshot.data.description == null
                    ? Campaign(
                        id: campaign.id,
                        imgUrl: campaign.imgUrl,
                        name: campaign.name)
                    : snapshot.data,
                scrollController: scrollController,
              ),
              closedColor: color,
              closedElevation: elevation,
              closedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              closedBuilder: (context, open) => InkWell(
                onTap: () {
                  if (onPressed != null) {
                    onPressed(snapshot.data);
                    return;
                  }
                  open();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Avatar(
                          snapshot.data.thumbnailUrl ?? snapshot.data.imgUrl),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "${snapshot.data.name}",
                          style: Theme.of(context)
                              .textTheme
                              .title
                              .merge(textStyle),
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
