import 'package:flutter/material.dart';
import 'package:one_d_m/components/empty.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/components/news_post.dart';
import 'package:one_d_m/models/news.dart';
import 'package:one_d_m/provider/campaign_manager.dart';
import 'package:provider/provider.dart';

class CampaignNews extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CampaignManager cm = context.watch<CampaignManager>();

    if (cm.loadingCampaign!)
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: LoadingIndicator(message: "Lade Neuigkeiten"),
      ));

    if (cm.campaign!.news.isEmpty)
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Empty(
          message: "Für dieses Projekt existieren noch keine Neuigkeiten.",
        ),
      );

    List<News> n = cm.campaign!.news;
    n.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: Column(
          children:
              n.map((news) => NewsPost(news, withHeader: false)).toList()),
    );
  }
}
