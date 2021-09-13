import 'package:flutter/material.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/api/stream_result.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/models/news.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/views/home/profile_page.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'news_post.dart';

class PostFeed extends StatefulWidget {
  const PostFeed({Key key}) : super(key: key);

  @override
  _PostFeedState createState() => _PostFeedState();
}

class _PostFeedState extends State<PostFeed> {
  Stream<StreamResult<List<News>>> _newsStream;

  @override
  void initState() {
    super.initState();
    _newsStream = Api().news().streamGet();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StreamResult<List<News>>>(
        stream: _newsStream,
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Text("News",
                        style:
                            ThemeManager.of(context).textTheme.dark.headline6),
                    XMargin(12),
                    LoadingIndicator(
                      size: 10,
                      strokeWidth: 2,
                    )
                  ],
                ),
              ),
            );
          }

          List<News> posts = snapshot.data.data ?? [];
          if (posts.isEmpty) {
            return NoContentProfilePage();
          }

          return MultiSliver(
            children: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text("News",
                      style: ThemeManager.of(context).textTheme.dark.headline6),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => NewsPost(
                      posts[index],
                      withHeader: true,
                      withDonationButton: true,
                    ),
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                    childCount: posts.length,
                  ),
                ),
              ),
            ],
          );
        });
  }
}
