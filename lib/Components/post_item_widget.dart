import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/NewsPost.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:one_d_m/Pages/CertifiedSessionPage.dart';
import 'package:one_d_m/utils/timeline.dart';

import 'NativeAd.dart';

abstract class PostItem {
  Widget buildHeading(BuildContext context);

  Widget buildPosts(BuildContext context);
}

class HeadingItem implements PostItem {
  final Stream<Session> session;

  HeadingItem(this.session);

  @override
  Widget buildHeading(BuildContext context) {
    return StreamBuilder(
      stream: session,
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          Session session = snapshot.data;
          return Container(
            margin:
                const EdgeInsets.only(bottom: 0.0, left: 12.0, right: 12.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                OpenContainer(
                  closedColor: Colors.transparent,
                  closedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  closedElevation: 0,
                  openBuilder: (context, close) => CertifiedSessionPage(
                    session: snapshot.data,
                  ),
                  closedBuilder: (_, open) => InkWell(
                    onTap: open,
                    child: CachedNetworkImage(
                      imageUrl: session.imgUrl ?? '',
                      imageBuilder: (context, imageProvider) => Container(
                        height: 58.0,
                        width: 88.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const XMargin(8.0),
                Text(
                  session.name ?? '',
                  maxLines: 2,
                  softWrap: true,
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(fontWeight: FontWeight.w700, fontSize: 18),
                ),
                const XMargin(8.0),
                Icon(
                  Icons.verified,
                  color: Helper.hexToColor("#71e34b"),
                )
              ],
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  @override
  Widget buildPosts(BuildContext context) => SizedBox.shrink();
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

            news.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            ///limit only to display latest two posts
            List<News> sublist = news.length > 2 ? news.sublist(0, 2) : news;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPosts(context, sublist),
                ///show more button if limit exceeds 2
                news.length > 2
                    ? _buildShowMore(context, news[0].sessionId)
                    : SizedBox.shrink(),
                Padding(
                  padding: const EdgeInsets.only(top: 0,bottom: 12.0),
                  child: Divider(),
                )
              ],
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      );

  List<Widget> _buildPostWidget(BuildContext context, List<News> post) {
    List<Widget> widgets = [];
    int adRate = Constants.AD_NEWS_RATE;
    int rateCount = 0;

    for (News n in post) {
      rateCount++;

      widgets.add(SizedBox(height: 480, child: NewsPost(n)));

      if (rateCount >= adRate) {
        widgets.add(NewsNativeAd());
        rateCount = 0;
      }
    }

    return widgets;
  }

  Widget _buildPosts(BuildContext context, List<News> post) {
    return ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        final isLast = index == post.length - 1;

        var item = post[index];
        int adRate = Constants.AD_NEWS_RATE;
        int rateCount = 0;

        Widget childItem = NewsPost(item);
        for (News n in post) {
          rateCount++;

          if (rateCount >= adRate) {
            childItem = NewsNativeAd();
            rateCount = 0;
          }
        }
        if (rateCount == 0) {
          childItem = NewsPost(item);
        }

        return new Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 48.0, right: 12.0),
              child: childItem,
            ),
            Positioned.fill(
              top: 0,
              left: 18,
              child: CustomPaint(
                foregroundPainter: TimelinePainter(
                  hideDefaultIndicator: false,
                  lineColor: Helper.hexToColor('#707070'),
                  indicatorColor: Helper.hexToColor('#2e313f'),
                  indicatorSize: 16,
                  indicatorStyle: PaintingStyle.fill,
                  isFirst: index == 0,
                  isLast: isLast,
                  lineGap: 8.0,
                  strokeCap: StrokeCap.butt,
                  strokeWidth: 2.5,
                  style: PaintingStyle.stroke,
                  itemGap: 0.0,
                ),
                child: SizedBox(
                ),
              ),
            ),
          ],
        );
      },
      itemCount: post.length,
    );
  }

  _buildShowMore(BuildContext context, String sessionId) => StreamBuilder(
      stream: DatabaseService.getSession(sessionId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return OpenContainer(
            closedColor: Colors.transparent,
            closedShape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            closedElevation: 0,
            openBuilder: (context, close) => CertifiedSessionPage(
              session: snapshot.data,
            ),
            closedBuilder: (context, open) => Container(
              margin: const EdgeInsets.only(top: 0.0, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  XMargin(context.screenWidth(percent: 0.1)),
                  FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.black)),
                    onPressed: open,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Mehr anzeigen',
                        style: Theme.of(context).textTheme.headline6.copyWith(
                            fontWeight: FontWeight.bold, fontSize: 18.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      });
}
