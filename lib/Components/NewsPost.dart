import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/News.dart';

import 'CampaignButton.dart';
import 'package:timeago/timeago.dart' as timeago;

class NewsPost extends StatelessWidget {
  News news;
  bool withCampaign, isDark;

  NewsPost(this.news, {this.withCampaign = true, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Material(
        clipBehavior: Clip.antiAlias,
        color: isDark ? ColorTheme.darkBlue : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.black12),
            borderRadius: BorderRadius.circular(5)),
        child: Column(
          children: <Widget>[
            withCampaign
                ? CampaignButton(
                    news.campaignId,
                    textStyle: TextStyle(),
                    campaign: Campaign(
                        url: news.campaignImgUrl,
                        id: news.campaignId,
                        name: news.campaignName),
                  )
                : Container(),
            Container(
              height: 260,
              child: Stack(
                children: <Widget>[
                  CachedNetworkImage(
                    width: double.infinity,
                    imageUrl: news.imageUrl,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(),
                    ),
                    fit: BoxFit.cover,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                            Colors.black.withOpacity(.7),
                            Colors.black.withOpacity(0)
                          ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        timeago.format(news.createdAt, locale: "de"),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    news.title,
                    style: Theme.of(context)
                        .textTheme
                        .title
                        .copyWith(color: isDark ? Colors.white : Colors.black),
                  ),
                  SizedBox(height: 5),
                  Text(
                    news.shortText,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    news.text,
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.black),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
