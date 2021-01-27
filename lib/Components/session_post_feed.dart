import 'package:flutter/material.dart';
import 'package:one_d_m/Components/post_item_widget.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';

class SessionPostFeed extends StatefulWidget {
  final List<String> userSessions;

  const SessionPostFeed({Key key, this.userSessions}) : super(key: key);

  @override
  _SessionPostFeedState createState() => _SessionPostFeedState();
}

class _SessionPostFeedState extends State<SessionPostFeed> {
  List<PostItem> postItem = [];

  @override
  void initState() {
    widget.userSessions.forEach((element) {
      postItem.add(HeadingItem(DatabaseService.getSessionFuture(element)));
      postItem
          .add(PostContentItem(DatabaseService.getPostBySessionId(element)));
    });
    super.initState();
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
