import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/CustomOpenContainer.dart';
import 'package:one_d_m/Components/NewsPost.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/keep_alive_stream.dart';
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
    return KeepAliveStreamBuilder(
      stream: session,
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          Session session = snapshot.data;
          return Container(
            margin: const EdgeInsets.only(
                bottom: 0.0, left: 12.0, right: 12.0, top: 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomOpenContainer(
                  closedColor: Colors.transparent,
                  closedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  closedElevation: 0,
                  openBuilder: (context, close,scrollController) => CertifiedSessionPage(
                    session: snapshot.data,
                    scrollController: scrollController,
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

class PostContentItem extends StatefulWidget implements PostItem {
  final Stream<List<News>> post;

  PostContentItem(this.post);

  @override
  Widget buildHeading(BuildContext context) => SizedBox.shrink();

  @override
  Widget buildPosts(BuildContext context) => KeepAliveStreamBuilder(
        stream: post,
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            List<News> news = snapshot.data;

            news.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            ///limit only to display latest two posts
            List<News> sublist = news.length > 5 ? news.sublist(0, 5) : news;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [

                ListView(
                  shrinkWrap: true,
                  addAutomaticKeepAlives: true,
                  padding: EdgeInsets.only(top: 20),
                  physics: const NeverScrollableScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  children: _buildPostWidgets(context, sublist),
                ),
                ///show more button if limit exceeds 2
                news.length > 5
                    ? _buildShowMore(context, news[0].sessionId)
                    : SizedBox.shrink(),
                Padding(
                  padding: const EdgeInsets.only(top: 0, bottom: 8.0),
                  child: Divider(),
                )
              ],
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      );

  List<Widget> _buildPostWidgets(BuildContext context, List<News> post) {
    List<Widget> widgets = [];
    int adRate = Constants.AD_NEWS_RATE;
    int rateCount = 0;
    for (var i = 0; i < post.length; i++) {
      bool isFirst = i == 0;
      bool isLast = i == post.length - 1;
      rateCount++;

      widgets.add(Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 32.0, right: 12.0,top: 0),
            child: NewsPost(post[i],withCampaign: false,),
          ),
          Positioned.fill(
            top: isFirst?10:0,
            left: 12,
            child: CustomPaint(
              foregroundPainter: TimelinePainter(
                hideDefaultIndicator: false,
                lineColor: Helper.hexToColor('#707070'),
                indicatorColor: Helper.hexToColor('#2e313f'),
                indicatorSize: 12,
                indicatorStyle: PaintingStyle.fill,
                isFirst: isFirst,
                isLast: isLast,
                lineGap: 4.0,
                strokeCap: StrokeCap.butt,
                strokeWidth: 2.5,
                style: PaintingStyle.stroke,
                itemGap: 0.0,
              ),
              child: SizedBox(),
            ),
          ),
        ],
      ));

      ///add native add only if post length is higher than adrate
      if (post.length > adRate) {
        if (rateCount >= adRate) {
          widgets.add(Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 32.0, right: 12.0),
                child: NewsNativeAd(),
              ),
              Positioned.fill(
                top: 0,
                left: 12,
                child: CustomPaint(
                  foregroundPainter: TimelinePainter(
                    hideDefaultIndicator: false,
                    lineColor: Helper.hexToColor('#707070'),
                    indicatorColor: Helper.hexToColor('#f9a900'),
                    indicatorSize: 12,
                    indicatorStyle: PaintingStyle.fill,
                    isFirst: false,
                    isLast: isLast,
                    lineGap: 4.0,
                    strokeCap: StrokeCap.butt,
                    strokeWidth: 2.5,
                    style: PaintingStyle.stroke,
                    itemGap: 0.0,

                  ),
                  child: SizedBox(),
                ),
              ),
            ],
          ));
          rateCount = 0;
        }
      }
    }

    return widgets;
  }

  _buildShowMore(BuildContext context, String sessionId) => StreamBuilder(
      stream: DatabaseService.getSession(sessionId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return CustomOpenContainer(
            closedColor: Colors.transparent,
            closedShape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            closedElevation: 0,
            openBuilder: (context, close,scrollController) => CertifiedSessionPage(
              session: snapshot.data,
              scrollController: scrollController,
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
                    child: Text(
                      'Zur Session',
                      style: Theme.of(context).textTheme.headline6.copyWith(
                          fontWeight: FontWeight.bold, fontSize: 18.0),
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

  @override
  State<StatefulWidget> createState() {
    throw UnimplementedError();
  }

}
