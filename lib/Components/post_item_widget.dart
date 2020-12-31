import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/Session.dart';

abstract class PostItem {
  Widget buildHeading(BuildContext context);

  Widget buildPosts(BuildContext context);

  Widget buildTimeline(BuildContext context);
}

class HeadingItem implements PostItem {
  final Stream<BaseSession> session;

  HeadingItem(this.session);

  @override
  Widget buildHeading(BuildContext context) {
    return StreamBuilder(
      stream: session,
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          BaseSession session = snapshot.data;
          return Text(
            session.id,
            style: Theme.of(context).textTheme.headline4,
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  @override
  Widget buildPosts(BuildContext context) => SizedBox.shrink();

  @override
  Widget buildTimeline(BuildContext context) => SizedBox.shrink();
}

class PostContentItem implements PostItem {
  final Stream<List<News>> post;

  PostContentItem(this.post);

  @override
  Widget buildHeading(BuildContext context) => SizedBox.shrink();

  @override
  Widget buildPosts(BuildContext context) => StreamBuilder(
        stream: post,
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            List<News> news = snapshot.data;
            return ListView.builder(
              itemCount: news.length,
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemBuilder: (_,index){
                var item = news[index];
                return Text(item.text);
              },
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      );

  @override
  Widget buildTimeline(BuildContext context) => SizedBox.shrink();

  List<Widget> _buildPostWidgets(List<News> news) {
    List<Widget> widgets = [];
    for (News n in news) {
      widgets.add(Text(n.title));
    }
    return widgets;
  }
}

class TimelineItem implements PostItem {
  final News post;

  TimelineItem(this.post);

  @override
  Widget buildHeading(BuildContext context) => SizedBox.shrink();

  @override
  Widget buildPosts(BuildContext context) => SizedBox.shrink();

  @override
  Widget buildTimeline(BuildContext context) => Text(
        post.createdAt.toString(),
        style: Theme.of(context).textTheme.subtitle1,
      );
}
