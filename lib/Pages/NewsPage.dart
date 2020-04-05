import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/CampaignButton.dart';
import 'package:one_d_m/Components/UserButton.dart';
import 'package:one_d_m/Helper/News.dart';

class NewsPage extends StatelessWidget {
  News news;
  MediaQueryData _mq;

  NewsPage(this.news);

  @override
  Widget build(BuildContext context) {
    _mq = MediaQuery.of(context);
    return Container(
      height: _mq.size.height * .95,
      child: Material(
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              children: <Widget>[
                CachedNetworkImage(
                  width: _mq.size.width,
                  height: 250,
                  imageUrl: news.imageUrl,
                  fit: BoxFit.cover,
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 60,
                    height: 6,
                    margin: EdgeInsets.only(top: 5),
                    child: Material(
                      color: Colors.white60,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        news.title,
                        style: Theme.of(context).textTheme.title,
                      ),
                      SizedBox(height: 5),
                      Text(news.text),
                      SizedBox(height: 20),
                      UserButton(news.userId),
                      SizedBox(height: 10),
                      CampaignButton(news.campaignId)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
