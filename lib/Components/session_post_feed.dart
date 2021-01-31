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
  final String uid;

  const SessionPostFeed(
      {Key key, this.uid})
      : super(key: key);

  @override
  SessionPostFeedState createState() => SessionPostFeedState();
}

class SessionPostFeedState extends State<SessionPostFeed> {
  final StreamController _myPostController = StreamController.broadcast();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _myPostController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildStream();
  }

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

  Widget _buildStream() => StreamBuilder(
        stream: DatabaseService.getCertifiedSessions(),
        builder: (_, allSessionsSnap) {
          return StreamBuilder(
            stream: DatabaseService.getSubscribedCampaignsStream(widget.uid),
            builder: (__, myCampaignSnap) {
              List<Session> allSessions = allSessionsSnap?.data ?? [];
              List<Session> userSessions = [];
              List<Campaign> userCampaigns = myCampaignSnap?.data ?? [];

              for (Session s in allSessions) {
                Future<bool> isFollow =
                    DatabaseService.userIsFollowSession(widget.uid, s.id);
                isFollow.then((follow) {
                  if (follow) {
                    userSessions.add(s);
                  }
                });
              }
              return _buildPostStream(userSessions, userCampaigns);
            },
          );
        },
      );

  Widget _buildPostStream(
          List<Session> userSessions, List<Campaign> userCampaigns) =>
      StreamBuilder(
        stream: DatabaseService.getAllPosts(),
        builder: (_, snapshot) {
          if (!snapshot.hasData)
            return SliverToBoxAdapter(child: SizedBox.shrink());
          List<News> allNews = snapshot.data;
          if (allNews.isEmpty)
            return SliverToBoxAdapter(child: SizedBox.shrink());

          List<News> myPosts = [];
          List<UserPost> userPosts = [];
          List<PostItem> postItem = [];

          for (News n in allNews) {
            for (Session s in userSessions) {
              if (n.sessionId == s.id) {
                myPosts.add(n);
              }
            }
            if (n.sessionId == '') {
              for (Campaign c in userCampaigns) {
                if (n.campaignId == c.id) {
                  myPosts.add(n);
                }
              }
            }
          }

          myPosts.sort((a, b) => b.createdAt?.compareTo(a.createdAt));

          for (News p in myPosts) {
            UserPost up = UserPost(
                id: p.sessionId != '' ? p.sessionId : p.campaignId,
                isSession: p.sessionId != '');
            userPosts.add(up);
          }
          List<UserPost> p = [];
          p.addAll(userPosts.where((a) => p.every((b) => a.id != b.id)));
          for (UserPost up in p) {
            postItem.add(HeadingItem(
                session: up.isSession
                    ? DatabaseService.getSessionFuture(up.id)
                    : null,
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
          return SliverList(
              delegate: SliverChildListDelegate(_buildPostWidgets(postItem)));
        },
      );

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
