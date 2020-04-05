import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Components/CampaignPageRoute.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/News.dart';

import 'NewsBody.dart';

class NewsPost extends StatelessWidget {
  News news;

  NewsPost(this.news);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: () {
              Navigator.push(
                  context, CampaignPageRoute(Campaign(id: news.campaignId, imgUrl: news.campaignImgUrl)));
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  Avatar(
                    news.campaignImgUrl,
                  ),
                  SizedBox(width: 10),
                  Text(
                    news.campaignName,
                    style: Theme.of(context).textTheme.title,
                  ),
                ],
              ),
            ),
          ),
          NewsBody(news),
          Divider(),
        ],
      ),
    );
  }
}
