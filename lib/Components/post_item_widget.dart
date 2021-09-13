import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/helper/database_service.dart';
import 'package:one_d_m/models/campaign_models/campaign.dart';
import 'package:one_d_m/models/news.dart';
import 'package:one_d_m/models/session_models/certified_session.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/utils/timeline.dart';
import 'package:one_d_m/views/campaigns/campaign_page.dart';
import 'package:one_d_m/views/sessions/session_page.dart';

import 'custom_open_container.dart';
import 'keep_alive_stream.dart';
import 'margin.dart';
import 'native_ad.dart';
import 'news_post.dart';

abstract class PostItem {
  Widget buildHeading(BuildContext context);

  Widget buildPosts(BuildContext context);
}

class HeadingItem implements PostItem {
  final Stream<CertifiedSession> session;
  final Stream<Campaign> campaign;
  final bool isSession;

  HeadingItem({this.isSession, this.session, this.campaign});

  @override
  Widget buildHeading(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return KeepAliveStreamBuilder(
      stream: isSession ? session : campaign,
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          CertifiedSession session;
          Campaign campaign;
          isSession ? session = snapshot.data : campaign = snapshot.data;
          return Container(
            margin: const EdgeInsets.only(
                bottom: 0.0, left: 12.0, right: 12.0, top: 0),
            child: CustomOpenContainer(
              closedColor: ColorTheme.appBg,
              closedElevation: 0,
              openBuilder: (context, close, scrollController) => isSession
                  ? SessionPage(
                      snapshot.data,
                    )
                  : CampaignPage(
                      campaign,
                      scrollController: scrollController,
                    ),
              closedBuilder: (_, open) => Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CachedNetworkImage(
                    imageUrl:
                        !isSession ? campaign?.imgUrl : session?.imgUrl ?? '',
                    imageBuilder: (context, imageProvider) => Container(
                      height: 58.0,
                      width: 88.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Constants.radius),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const XMargin(8.0),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(
                            isSession
                                ? session.name ?? ''
                                : campaign.name ?? '',
                            maxLines: 1,
                            softWrap: true,
                            style: _theme.textTheme.dark.headline6
                                .copyWith(fontWeight: FontWeight.w600)),
                        isSession
                            ? AutoSizeText('Unterstützt NOT FOUND',
                                maxLines: 1,
                                softWrap: true,
                                style: _theme.textTheme.dark
                                    .withOpacity(.7)
                                    .bodyText1
                                    .copyWith(fontWeight: FontWeight.w400))
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                ],
              ),
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

  PostContentItem({this.post});

  @override
  Widget buildHeading(BuildContext context) => SizedBox.shrink();

  @override
  Widget buildPosts(BuildContext context) {
    return KeepAliveStreamBuilder(
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
                physics: const NeverScrollableScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                children: _buildPostWidgets(context, sublist),
              ),

              ///show more button if limit exceeds 2
              news.length >= 5
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
  }

  List<Widget> _buildPostWidgets(BuildContext context, List<News> post) {
    List<Widget> widgets = [];
    int adRate = Constants.AD_NEWS_RATE;
    int rateCount = 0;
    ThemeManager _theme = ThemeManager.of(context);
    for (var i = 0; i < post.length; i++) {
      bool isFirst = i == 0;
      bool isLast = i == post.length - 1;
      rateCount++;

      widgets.add(Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 28.0, right: 12.0, top: 0),
            child: NewsPost(
              post[i],
              withHeader: false,
              withDonationButton: true,
            ),
          ),
          Positioned.fill(
            top: isFirst ? 10 : 0,
            left: 12,
            child: CustomPaint(
              foregroundPainter: TimelinePainter(
                hideDefaultIndicator: false,
                lineColor: _theme.colors.dark.withOpacity(.2),
                indicatorColor: _theme.colors.dark,
                indicatorSize: 8,
                indicatorStyle: PaintingStyle.fill,
                isFirst: isFirst,
                isLast: isLast,
                lineGap: 0.0,
                strokeCap: StrokeCap.round,
                strokeWidth: 1,
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
                padding: const EdgeInsets.only(
                    left: 28.0, right: 12.0, top: 6, bottom: 6),
                child: NewsNativeAd(
                  id: Constants.ADMOB_NEWS_ID,
                ),
              ),
              Positioned.fill(
                top: 0,
                left: 12,
                child: CustomPaint(
                  foregroundPainter: TimelinePainter(
                    hideDefaultIndicator: false,
                    lineColor: _theme.colors.dark.withOpacity(.2),
                    indicatorColor: Colors.orange,
                    indicatorSize: 8,
                    indicatorStyle: PaintingStyle.fill,
                    isFirst: false,
                    isLast: isLast,
                    lineGap: 0.0,
                    strokeCap: StrokeCap.butt,
                    strokeWidth: 1,
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
        ThemeManager _theme = ThemeManager.of(context);
        if (snapshot.hasData) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomOpenContainer(
                closedColor: _theme.colors.contrast,
                closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
                closedElevation: 0,
                openBuilder: (context, close, scrollController) =>
                    SessionPage(snapshot.data),
                closedBuilder: (context, open) => Material(
                  borderRadius: BorderRadius.circular(6),
                  color: _theme.colors.contrast,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Zur CertifiedSession',
                            style:
                                TextStyle(color: _theme.colors.textOnContrast)),
                        XMargin(6),
                        Icon(
                          Icons.arrow_forward,
                          color: _theme.colors.textOnContrast,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
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
