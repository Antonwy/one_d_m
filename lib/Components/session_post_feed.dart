import 'dart:async';

import 'package:flutter/material.dart';
import 'package:one_d_m/Components/post_item_widget.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/HomePage/ProfilePage.dart';
import 'package:provider/provider.dart';

class SessionPostFeed extends StatefulWidget {
  const SessionPostFeed({Key key}) : super(key: key);

  @override
  SessionPostFeedState createState() => SessionPostFeedState();
}

class SessionPostFeedState extends State<SessionPostFeed> {
  String uid;

  @override
  Widget build(BuildContext context) {
    uid = context.watch<UserManager>().uid;
    return _buildPostStream();
  }

  Widget _buildPostStream() => StreamBuilder(
        stream: DatabaseService.getCertifiedSessions(),
        builder: (_, allSessionsSnap) {
          return StreamBuilder(
            stream: DatabaseService.getSubscribedCampaignsStream(uid),
            builder: (__, myCampaignSnap) {
              List<Session> allSessions = allSessionsSnap?.data ?? [];
              List<Session> userSessions = [];
              List<Campaign> userCampaigns = myCampaignSnap?.data ?? [];

              for (Session s in allSessions) {
                Future<bool> isFollow =
                    DatabaseService.userIsFollowSession(uid, s.id);
                isFollow.then((follow) {
                  if (follow) {
                    userSessions.add(s);
                  }
                });
              }
              return _buildPost(userSessions, userCampaigns);
            },
          );
        },
      );

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

  Widget _buildPost(List<Session> userSession, List<Campaign> userCampaigns) =>
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
            for (Session s in userSession) {
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
          return postItem.isEmpty
              ? NoContentProfilePage()
              : SliverList(
                  delegate:
                      SliverChildListDelegate(_buildPostWidgets(postItem)));
        },
      );

  Widget _buildNewsTitleWidget() => Padding(
        padding: const EdgeInsets.only(left: 12, bottom: 10),
        child: Text(
          "News",
          style: ThemeManager.of(context).textTheme.dark.headline6.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
        ),
      );
}

class UserPost {
  String id;
  bool isSession;

  UserPost({this.id, this.isSession});
}
