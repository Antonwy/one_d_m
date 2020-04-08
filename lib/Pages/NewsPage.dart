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
      height: _mq.size.height * .7,
      child: Material(
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 60,
                    height: 6,
                    margin: EdgeInsets.only(top: 5),
                    child: Material(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  news.title,
                  style: Theme.of(context).textTheme.title.copyWith(fontSize: 30),
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
    );
  }
}
