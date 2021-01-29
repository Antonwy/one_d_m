import 'package:flutter/material.dart';
import 'package:one_d_m/Components/post_item_widget.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Pages/HomePage/ProfilePage.dart';

class SessionPostFeed extends StatefulWidget {
  final List<Session> userSessions;

  const SessionPostFeed({Key key, this.userSessions}) : super(key: key);
  @override
  _SessionPostFeedState createState() => _SessionPostFeedState();
}

class _SessionPostFeedState extends State<SessionPostFeed> {
  ThemeManager _theme;

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return StreamBuilder<List<News>>(
        stream: DatabaseService.getSessionPosts(),
        builder: (context, AsyncSnapshot<List<News>> snapshot) {
          if (!snapshot.hasData)
            return SliverToBoxAdapter(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(_theme.colors.dark),
                ),
              ),
            );
          List<News> news = snapshot.data;

          List<String> sessionsWithPost = [];
          List<String> mySessionPosts = [];
          List<PostItem> postItem = [];

          news.forEach((element) {
            sessionsWithPost.add(element.sessionId);
          });
          //filter user following session posts
          for (Session s in widget.userSessions) {
            if (sessionsWithPost.contains(s.id)) {
              mySessionPosts.add(s.id);
            }
          }

          ///remove duplicating ids
          mySessionPosts.toSet().toList().forEach((element) {
            postItem
                .add(HeadingItem(DatabaseService.getSessionFuture(element)));
            postItem.add(
                PostContentItem(DatabaseService.getPostBySessionId(element)));
          });
          if (postItem.isNotEmpty) {
            return SliverList(
                delegate: SliverChildListDelegate(_buildPostWidgets(postItem)));
          } else {
            return NoContentProfilePage();
          }
        });
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

  Widget _buildNewsTitleWidget() => Padding(
        padding: const EdgeInsets.only(left: 12, bottom: 10),
        child: Text(
          "News",
          style: _theme.textTheme.dark.headline6
              .copyWith(fontWeight: FontWeight.w600),
        ),
      );
}
