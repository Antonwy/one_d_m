import 'package:flutter/material.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Components/CampaignPageRoute.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/News.dart';

import 'CampaignButton.dart';
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
          CampaignButton(
            news.campaignId,
            campaign: Campaign(
                imgUrl: news.campaignImgUrl,
                id: news.campaignId,
                name: news.campaignName),
          ),
          NewsBody(news),
          Divider(),
        ],
      ),
    );
  }
}
