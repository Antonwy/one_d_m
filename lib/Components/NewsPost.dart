import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Pages/CampaignPage.dart';

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
          SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (c) =>
                          CampaignPage(campaignId: news.projectId)));
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: NetworkImage(news.imageUrl),
                  ),
                  SizedBox(width: 10),
                  Text(
                    news.title,
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
