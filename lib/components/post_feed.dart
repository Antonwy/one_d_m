import 'package:flutter/material.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/api/stream_result.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/components/warning_icon.dart';
import 'package:one_d_m/models/news.dart';
import 'package:one_d_m/views/home/profile_page.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'news_post.dart';

class PostFeed extends StatefulWidget {
  const PostFeed({Key? key}) : super(key: key);

  @override
  _PostFeedState createState() => _PostFeedState();
}

class _PostFeedState extends State<PostFeed> {
  Stream<StreamResult<List<News?>>>? _newsStream;

  @override
  void initState() {
    super.initState();
    _newsStream = Api().news().streamGet();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StreamResult<List<News?>>>(
        stream: _newsStream,
        builder: (_, snapshot) {
          print(snapshot);
          Widget heading = SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Text("News", style: Theme.of(context).textTheme.headline6),
            ),
          );

          if (snapshot.hasError) {
            heading = SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    WarningIcon(size: 14),
                    XMargin(6),
                    Text("News", style: Theme.of(context).textTheme.headline6),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            heading = SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Text("News", style: Theme.of(context).textTheme.headline6),
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

          List<News?> posts = snapshot.data?.data ?? [];
          if (snapshot.hasData && posts.isEmpty) {
            return NoContentProfilePage();
          }

          return MultiSliver(
            children: [
              heading,
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverAnimatedOpacity(
                  duration: Duration(milliseconds: 250),
                  opacity: snapshot.hasData ? 1 : 0,
                  sliver: snapshot.hasData
                      ? SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => NewsPost(
                              posts[index]!,
                              withDonationButton: true,
                            ),
                            addAutomaticKeepAlives: false,
                            addRepaintBoundaries: false,
                            childCount: posts.length,
                          ),
                        )
                      : SliverToBoxAdapter(),
                ),
              ),
            ],
          );
        });
  }
}
