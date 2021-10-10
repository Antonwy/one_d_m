import 'dart:async';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/components/video_or_image.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/models/campaign_models/campaign.dart';
import 'package:one_d_m/models/news.dart';
import 'package:one_d_m/models/session_models/session.dart';
import 'package:one_d_m/views/campaigns/campaign_page.dart';
import 'package:one_d_m/views/donations/donation_dialog.dart';
import 'package:one_d_m/views/sessions/session_page.dart';
import 'package:visibility_detector/visibility_detector.dart';

class NewsPost extends StatefulWidget {
  final News? news;
  final bool withHeader, withDonationButton;
  bool isInView;
  final VoidCallback? onPostSeen;
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
  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.news!.id!),
      onVisibilityChanged: (VisibilityInfo info) {
        var visiblePercentage = (info.visibleFraction) * 100;
        if (mounted) {
          if (visiblePercentage == 100) {
            if (widget.onPostSeen != null) widget.onPostSeen!();
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
        child: Card(
          clipBehavior: Clip.antiAlias,
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
                        ? _buildCreatorTitle(widget.news!)
                        : SizedBox.shrink(),
                    widget.news!.text!.isEmpty
                        ? Container()
                        : _buildExpandableContent(context, widget.news!.text!)
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
                style: context.theme.textTheme.bodyText1!
                    .copyWith(fontSize: 15, fontWeight: FontWeight.w400),
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
                            )),
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
                softWrap: true,
                textAlign: TextAlign.start,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(fontSize: 15, fontWeight: FontWeight.w400),
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
                      )),
                )),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _postButton({required String text, void Function()? onPressed}) {
    return InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ));
  }

  Future<void> _donate() async {
    DonationDialog.show(context,
        campaignId: widget.news!.campaignId, sessionId: widget.news!.sessionId);
  }

  Widget _buildCreatorTitle(News news) {
    bool _isSessionNews = news.sessionId?.isNotEmpty ?? false;

    return Padding(
        padding:
            EdgeInsets.fromLTRB(12, 12, 0, news.text?.isEmpty ?? true ? 12 : 0),
        child: _isSessionNews
            ? GestureDetector(
                onTap: () async {
                  Session? session =
                      await (Api().sessions().getOne(news.sessionId));
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SessionPage(session)));
                },
                child: Text('@${news.sessionName}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    )),
              )
            : GestureDetector(
                onTap: () async {
                  Campaign? campaign =
                      await Api().campaigns().getOne(news.campaignId);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CampaignPage(campaign!)));
                },
                child: Text('@${news.campaignName}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    )),
              ));
  }
}
