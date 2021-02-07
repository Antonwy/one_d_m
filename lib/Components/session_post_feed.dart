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

class PostFeed extends StatefulWidget {
  const PostFeed({Key key}) : super(key: key);

  @override
  PostFeedState createState() => PostFeedState();
}

class PostFeedState extends State<PostFeed> {
  String uid;

  @override
  void initState() {
    super.initState();
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
              child: Center(
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
              )),
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
    List<News> orderedPosts = [];
    int adRate = Constants.AD_NEWS_RATE;
    int rateCount = 0;

    if (posts.isNotEmpty) {
      widgets.add(_buildNewsTitleWidget());
    }

    for (var i = 0; i < posts.length; i++) {
      //display video post on top of the list
      if (posts[i]?.videoUrl?.isNotEmpty ?? false) {
        postWithVideos.add(posts[i]);
      } else {
        postNoVideos.add(posts[i]);
      }
      orderedPosts = [...postWithVideos, ...postNoVideos];
    }

    for (var i = 0; i < orderedPosts.length; i++) {
      rateCount++;
      widgets.add(
        Padding(
          padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: NewsPost(
            orderedPosts[i],
            withCampaign: false,
            withDonationButton: true,
          ),
        ),
      );

      ///add native add only if post length is higher than adrate
      if (orderedPosts.length > adRate) {
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
