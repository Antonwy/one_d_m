import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:one_d_m/Pages/CertifiedSessionPage.dart';
import 'package:one_d_m/utils/ago.dart';
import 'package:one_d_m/utils/timeline.dart';

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
            margin: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CachedNetworkImage(
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
                ///post content
                Timeline(
                  children: _buildPostWidget(context, sublist),
                  indicators: _buildAgoWidgets(context, sublist),
                  indicatorColor: Helper.hexToColor('#707070'),
                  lineGap: 24.0,
                  strokeWidth: 3.0,
                  gutterSpacing: 8.0,
                  itemGap: 24,
                ),
                ///show more button if limit exceeds 2
                news.length > 2
                    ? _buildShowMore(context, news[0].sessionId)
                    : SizedBox.shrink()
              ],
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      );

  List<Widget> _buildPostWidget(BuildContext context, List<News> post) {
    List<Widget> widgets = [];
    for (News p in post) {
      widgets.add(_buildPostItem(context, p));
    }
    return widgets;
  }

  List<Widget> _buildAgoWidgets(BuildContext context, List<News> post) {
    List<Widget> widgets = [];
    for (News p in post) {
      widgets.add(_buildTimelineWidget(context, p.createdAt, false));
    }
    return widgets;
  }

  _buildPostItem(BuildContext context, News post) => Container(
        height: 280,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            boxShadow: [
              BoxShadow(
                color: ThemeManager.of(context).colors.dark.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 2,
                offset: Offset(3, 2), // changes position of shadow
              ),
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
                imageUrl: post.imageUrl ?? '',
                imageBuilder: (context, imageProvider) => Container(
                      height: 170.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12)),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                errorWidget: (context, url, error) =>
                    _buildPlaceholder(context),
                placeholder: (context, url) => _buildPlaceholder(context)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AutoSizeText(
                post.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AutoSizeText(
                post.text,
                maxLines: 3,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(color: Helper.hexToColor('#707070')),
              ),
            )
          ],
        ),
      );

  _buildTimelineWidget(
          BuildContext context, DateTime createdAt, bool isLastItem) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Text('${timeAgoSinceDate(createdAt)}',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(color: Helper.hexToColor('#707070'))),
          ),
        ],
      );

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
              margin: const EdgeInsets.only(top: 12.0,bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  XMargin(context.screenWidth(percent: 0.2)),
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

  Widget _buildPlaceholder(BuildContext context) => Container(
        color: ThemeManager.of(context).colors.dark.withOpacity(0.7),
        height: 170,
        width: double.infinity,
        child: Center(
          child: Icon(
            Icons.image_outlined,
            color: ThemeManager.of(context).colors.contrast,
          ),
        ),
      );
}
