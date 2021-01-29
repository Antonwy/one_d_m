import 'dart:async';

import 'package:flutter/material.dart';
import 'package:one_d_m/Components/post_item_widget.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';

class SessionPostFeed extends StatefulWidget {
  final Function() notifyFeed;
  final List<Session> userSessions;
  final String uid;
  final List<Campaign> userCampaigns;

  const SessionPostFeed(
      {Key key, this.userSessions, this.userCampaigns, this.uid, this.notifyFeed})
      : super(key: key);

  @override
  SessionPostFeedState createState() => SessionPostFeedState();
}

class SessionPostFeedState extends State<SessionPostFeed> {
  List<PostItem> postItem = [];
  List<String> mySessionIds = [];
  List<String> myCampaignIds = [];
  List<UserPost> userPosts = [];
  final StreamController _myPostController = StreamController.broadcast();

  @override
  void initState() {
    print('???${widget.userCampaigns.length}');
    DatabaseService.getAllPosts().listen((news) {
      mySessionIds.clear();
      myCampaignIds.clear();
      userPosts.clear();
      List<News> myPosts = [];

      for (News n in news) {
        for (Session s in widget.userSessions) {
          if (n.sessionId == s.id) {
            myPosts.add(n);
          }
        }
        if (n.sessionId == '') {
          for (Campaign c in widget.userCampaigns) {
            if (n.campaignId == c.id) {
              myPosts.add(n);
            }
          }
        }
      }

      myPosts.sort((a, b) => b.createdAt?.compareTo(a.createdAt));

      for (News p in myPosts) {
        setState(() {
          UserPost up = UserPost(
              id: p.sessionId != '' ? p.sessionId : p.campaignId,
              isSession: p.sessionId != '');
          userPosts.add(up);
        });
      }

      _myPostController.add(news);
    });

    _myPostController.stream.listen((event) {
      if (userPosts.isNotEmpty) {
        List<UserPost> p = [];
        p.addAll(userPosts.where((a) => p.every((b) => a.id != b.id)));
        for (UserPost up in p) {
          postItem.add(HeadingItem(
              session:
                  up.isSession ? DatabaseService.getSessionFuture(up.id) : null,
              campaign: up.isSession
                  ? null
                  : DatabaseService.getCampaignStream(up.id),
              isSession: up.isSession));
          postItem.add(PostContentItem(
            post: up.isSession
                ? DatabaseService.getPostBySessionId(up.id)
                : DatabaseService.getNewsFromCampaignStream(up.id),
          ));
        }
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _myPostController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildUserPosts();
  }

  Widget _buildUserPosts() => postItem.isNotEmpty
      ? SliverList(
          delegate: SliverChildListDelegate(_buildPostWidgets(postItem)))
      : SliverToBoxAdapter(child: SizedBox.shrink());

  List<Widget> _buildPostWidgets(List<PostItem> post) {
    List<Widget> widgets = [];
    widgets.add(_buildNewsTitleWidget());
    for (PostItem p in post) {
      widgets.add(Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [p.buildHeading(context), p.buildPosts(context)],
      ));
    }
    return widgets;
  }

  Widget _buildNewsTitleWidget() => Padding(
        padding: const EdgeInsets.only(left: 12, bottom: 10),
        child: Text(
          "News",
          style: ThemeManager.of(context).textTheme.dark.headline6.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Helper.hexToColor('#3E313F')),
        ),
      );
}

class UserPost {
  String id;
  bool isSession;

  UserPost({this.id, this.isSession});
}
