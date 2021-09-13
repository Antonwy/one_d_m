import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/components/video_or_image.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/helper/database_service.dart';
import 'package:one_d_m/models/campaign_models/base_campaign.dart';
import 'package:one_d_m/models/campaign_models/campaign.dart';
import 'package:one_d_m/models/news.dart';
import 'package:one_d_m/models/session_models/certified_session.dart';
import 'package:one_d_m/models/session_models/session.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:one_d_m/utils/video/video_widget.dart';
import 'package:one_d_m/views/campaigns/campaign_page.dart';
import 'package:one_d_m/views/donations/donation_dialog.dart';
import 'package:one_d_m/views/sessions/session_page.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:visibility_detector/visibility_detector.dart';

import 'animated_future_builder.dart';
import 'bottom_dialog.dart';
import 'custom_open_container.dart';
import 'donation_widget.dart';

class NewsPost extends StatefulWidget {
  final News news;
  final bool withHeader, withDonationButton;
  bool isInView;
  final VoidCallback onPostSeen;
  final bool showAnimate;

  NewsPost(this.news,
      {this.withHeader = true,
      this.isInView = false,
      this.withDonationButton = false,
      this.onPostSeen,
      this.showAnimate = false});

  @override
  _NewsPostState createState() => _NewsPostState();
}

class _NewsPostState extends State<NewsPost> {
  bool _muted = true;
  bool _isSessionPost;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _isSessionPost = !(widget.news.sessionId?.isEmpty ?? true);
    return VisibilityDetector(
      key: Key(widget.news.id),
      onVisibilityChanged: (VisibilityInfo info) {
        var visiblePercentage = (info.visibleFraction) * 100;
        if (mounted) {
          if (visiblePercentage == 100) {
            if (widget?.onPostSeen != null) widget.onPostSeen();
            setState(() {
              widget.isInView = true;
            });
          } else {
            setState(() {
              widget.isInView = false;
            });
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Material(
          clipBehavior: Clip.antiAlias,
          color: ColorTheme.appBg,
          elevation: 1,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.radius)),
          child: Column(
            children: <Widget>[
              Container(
                height: 260,
                child: VideoOrImage(
                  imageUrl: widget.news?.imageUrl,
                  videoUrl: widget.news?.videoUrl,
                  blurHash: widget.news?.blurHash,
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    widget.withHeader
                        ? _buildCreatorTitle(widget.news)
                        : SizedBox.shrink(),
                    widget.news.text.isEmpty
                        ? Container()
                        : _buildExpandableContent(context, widget.news.text)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableContent(BuildContext context, String post) {
    ThemeManager _theme = ThemeManager.of(context);
    return ExpandableNotifier(
      child: Expandable(
        collapsed: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                post,
                maxLines: 3,
                softWrap: true,
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.w400),
              ),
            ),
            Divider(
              height: 1,
            ),
            Row(
              children: [
                widget.withDonationButton
                    ? _postButton(
                        onPressed: () async {
                          await _donate();
                        },
                        text: "Unterstützen")
                    : SizedBox.shrink(),
                post.length > 120
                    ? ExpandableButton(
                        child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Mehr',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: _theme.colors.dark)),
                      ))
                    : SizedBox.shrink()
              ],
            ),
          ],
        ),
        expanded: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                post,
                maxLines: null,
                softWrap: true,
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.w400),
              ),
            ),
            Divider(
              height: 1,
            ),
            Row(
              children: [
                widget.withDonationButton
                    ? _postButton(
                        onPressed: () async {
                          await _donate();
                        },
                        text: "Unterstützen")
                    : SizedBox.shrink(),
                ExpandableButton(
                    child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Weniger',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: _theme.colors.dark)),
                )),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _postButton({String text, void Function() onPressed}) {
    return InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            text,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: ThemeManager.of(context).colors.dark),
          ),
        ));
  }

  Future<void> _donate() async {
    DonationDialog.show(context,
        campaignId: widget.news.campaignId, sessionId: widget.news.sessionId);
  }

  Widget _buildCreatorTitle(News news) {
    bool _isSessionNews = news.sessionId?.isNotEmpty ?? false;

    return Padding(
        padding:
            EdgeInsets.fromLTRB(12, 12, 0, news.text?.isEmpty ?? true ? 12 : 0),
        child: _isSessionNews
            ? GestureDetector(
                onTap: () async {
                  Session session =
                      await Api().sessions().getOne(news.sessionId);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SessionPage(session)));
                },
                child: Text('@${news.sessionName}',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: ThemeManager.of(context).colors.dark)),
              )
            : GestureDetector(
                onTap: () async {
                  Campaign campaign =
                      await Api().campaigns().getOne(news.campaignId);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CampaignPage(campaign)));
                },
                child: Text('@${news.campaignName}',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: ThemeManager.of(context).colors.dark)),
              ));
  }
}

class _NewsHeader extends StatelessWidget {
  final String sessionId, campaignId;

  const _NewsHeader({Key key, this.campaignId, this.sessionId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedFutureBuilder(
        future: campaignId != null
            ? DatabaseService.getCampaign(campaignId)
            : DatabaseService.getSessionFuture(sessionId),
        builder: (context, snapshot) {
          if (snapshot.hasData)
            return CustomOpenContainer(
              openBuilder: (context, open, scrollController) =>
                  campaignId != null
                      ? CampaignPage(
                          snapshot.data,
                          scrollController: scrollController,
                        )
                      : SessionPage(snapshot.data),
              closedColor: ColorTheme.appBg,
              closedElevation: 0,
              closedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Constants.radius)),
              tappable: snapshot.hasData,
              closedBuilder: (context, open) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    RoundedAvatar(snapshot.data?.imgUrl ?? ''),
                    SizedBox(width: 10),
                    Expanded(
                      child: AutoSizeText(
                        "${snapshot.data.name}",
                        maxLines: 1,
                        style: ThemeManager.of(context)
                            .textTheme
                            .dark
                            .bodyText1
                            .copyWith(fontSize: 16),
                      ),
                    )
                  ],
                ),
              ),
            );
          return Container(height: 60);
        });
  }
}
