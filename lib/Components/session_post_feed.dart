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

List<News> seenPosts = [];

class PostFeed extends StatefulWidget {
  const PostFeed({Key key}) : super(key: key);

  @override
  PostFeedState createState() => PostFeedState();
}

class PostFeedState extends State<PostFeed> {
  String uid;
  List<News> _orderedPosts = [];

  @override
  void initState() {
    super.initState();
  }

  void _reOrderPost() {
    for (News sp in seenPosts) {
      for (int i = 0; i < _orderedPosts.length; i++) {
        if (sp.id == _orderedPosts[i].id) {
          _orderedPosts.removeAt(i);
          _orderedPosts.add(sp);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    uid = context.watch<UserManager>().uid;
    return StreamBuilder(
        //todo add pagination
        stream: DatabaseService.getAllPosts(),
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
    List<News> postWithVideos = [];
    List<News> postNoVideos = [];
    int adRate = Constants.AD_NEWS_RATE;
    int rateCount = 0;

    for (var i = 0; i < posts.length; i++) {
      //display video post on top of the list
      if (posts[i]?.videoUrl?.isNotEmpty ?? false) {
        postWithVideos.add(posts[i]);
      } else {
        postNoVideos.add(posts[i]);
      }
    }

    for (News sp in seenPosts) {
      postNoVideos.removeWhere((p) => p.id == sp.id);
      postNoVideos.add(sp);
    }
    _orderedPosts = [...postWithVideos, ...postNoVideos];
    _reOrderPost();

    for (News n in _orderedPosts) {
      rateCount++;
      widgets.add(
        Padding(
          padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: NewsPost(
            n,
            withHeader: true,
            withDonationButton: true,
            onPostSeen: () {
              seenPosts.add(n);
            },
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
        Text("Lade News")
      ],
    ));
  }
}
