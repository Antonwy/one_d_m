import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/HomePage/ProfilePage.dart';
import 'package:provider/provider.dart';

import 'NativeAd.dart';
import 'NewsPost.dart';

class PostFeed extends StatelessWidget {
  const PostFeed({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: DatabaseService.getMainFeedPosts(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return SliverToBoxAdapter(
              child: _LoadingIndicator(),
            );
          }

          List<News> post = snapshot.data;
          if (post.isEmpty) {
            return NoContentProfilePage();
          }

          return SliverList(
              delegate: SliverChildListDelegate(_buildPostWidgets(post)));
        });
  }

  List<Widget> _buildPostWidgets(List<News> posts) {
    List<Widget> widgets = [];
    int adRate = Constants.AD_NEWS_RATE;
    int rateCount = 0;

    widgets.clear();

    for (News n in posts) {
      rateCount++;
      widgets.add(
        Padding(
          padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: NewsPost(
            n,
            withHeader: true,
            withDonationButton: true,
          ),
        ),
      );

      ///add native add only if post length is higher than adrate
      if (Platform.isIOS && posts.length > adRate) {
        if (rateCount >= adRate) {
          widgets.add(
            Padding(
              padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
              child: NewsNativeAd(
                id: Constants.ADMOB_NEWS_ID,
              ),
            ),
          );
          rateCount = 0;
        }
      }
    }

    return widgets;
  }
}

class _LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: <Widget>[
        SizedBox(
          height: 20,
        ),
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(ColorTheme.blue),
        ),
        SizedBox(
          height: 10,
        ),
        Text("Lade Neuigkeiten")
      ],
    ));
  }
}
