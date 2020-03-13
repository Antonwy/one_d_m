import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/AnimatedFutureBuilder.dart';
import 'package:one_d_m/Components/UserButton.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Pages/CampaignPage.dart';

class NewsPage extends StatelessWidget {
  News news;

  NewsPage(this.news);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(news.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      )),
                  background: Image.network(
                    news.imageUrl,
                    fit: BoxFit.cover,
                  )),
            ),
          ];
        },
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(news.text),
              SizedBox(height: 20),
              UserButton(news.userId),
              SizedBox(height: 10),
              AnimatedFutureBuilder<Campaign>(
                  future: DatabaseService().getCampaign(news.campaignId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Campaign campaign = snapshot.data;
                      return Material(
                        borderRadius: BorderRadius.circular(5),
                        clipBehavior: Clip.antiAlias,
                        color: Colors.white,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (c) =>
                                        CampaignPage(campaign)));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                CircleAvatar(
                                  backgroundImage:
                                      CachedNetworkImageProvider(campaign.imgUrl),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "${campaign.name}",
                                  style: Theme.of(context).textTheme.title,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return Container(height: 20);
                  })
            ],
          ),
        ),
      ),
    );
  }
}
