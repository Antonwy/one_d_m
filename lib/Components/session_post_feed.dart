import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/HomePage/ProfilePage.dart';
import 'package:provider/provider.dart';

import 'NativeAd.dart';
import 'NewsPost.dart';

class SessionPostFeed extends StatefulWidget {
  const SessionPostFeed({Key key}) : super(key: key);

  @override
  SessionPostFeedState createState() => SessionPostFeedState();
}

class SessionPostFeedState extends State<SessionPostFeed> {
  String uid;
  bool _hasMorePosts = true;
  bool _isLoading = false;
  DocumentSnapshot _lastDocument;
  List<DocumentSnapshot> _posts = [];
  int _limit = 5;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    uid = context.watch<UserManager>().uid;
    // return _buildPostsStream();
    return StreamBuilder(
        stream: DatabaseService.getAllPosts(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return SliverToBoxAdapter(
              child: Center(
                child: CircularProgressIndicator(),
              ),
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

    for (var i = 0; i < posts.length; i++) {
      rateCount++;

      widgets.add(
        Padding(
          padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: NewsPost(
            posts[i],
            withCampaign: false,
            withDonationButton: true,
          ),
        ),
      );

      ///add native add only if post length is higher than adrate
      if (_posts.length > adRate) {
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
