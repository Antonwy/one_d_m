import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Pages/NewCampaignPage.dart';

import 'CustomOpenContainer.dart';

class CampaignHeader extends StatefulWidget {
  Campaign campaign;

  CampaignHeader(this.campaign);

  @override
  _CampaignHeaderState createState() => _CampaignHeaderState();
}

class _CampaignHeaderState extends State<CampaignHeader> {
  TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    textTheme = Theme.of(context).textTheme;

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 15),
        child: CustomOpenContainer(
          closedShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          closedElevation: 12,
          openBuilder: (context, close, scrollController) => NewCampaignPage(
              widget.campaign,
              scrollController: scrollController),
          closedBuilder: (context, open) => InkWell(
            onTap: () async {
              await precacheImage(
                  CachedNetworkImageProvider(widget.campaign.imgUrl), context,
                  size: Size(MediaQuery.of(context).size.width,
                      MediaQuery.of(context).size.height * .3 + 30),
                  onError: (context, stacktrace) => print(stacktrace));
              open();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl: widget.campaign.imgUrl,
                  height: 230,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.campaign.name,
                        style: textTheme.title,
                      ),
                      widget.campaign.shortDescription == null
                          ? Container()
                          : Text(widget.campaign.shortDescription),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
