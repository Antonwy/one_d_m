import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/components/donation_widget.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/components/video_or_image.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:one_d_m/models/campaign_models/campaign.dart';
import 'package:one_d_m/models/news.dart';
import 'package:one_d_m/models/session_models/session.dart';
import 'package:one_d_m/views/campaigns/campaign_page.dart';
import 'package:one_d_m/views/donations/donation_dialog.dart';
import 'package:one_d_m/views/sessions/session_page.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'formatted_text.dart';

class NewsPost extends StatefulWidget {
  final News news;
  final bool withDonationButton;

  NewsPost(this.news, {this.withDonationButton = false});

  @override
  _NewsPostState createState() => _NewsPostState();
}

class _NewsPostState extends State<NewsPost> {
  int _maxChars = 150;
  bool _showImage = true;

  @override
  Widget build(BuildContext context) {
    News news = widget.news;

    _showImage = news.imageUrl != null || news.videoUrl != null;

    if (!_showImage) _maxChars = 300;

    ValueNotifier<bool> _loading = ValueNotifier(false);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            news.campaignName == null
                ? SizedBox.shrink()
                : ListTile(
                    onTap: () async {
                      try {
                        late Widget toWidget;
                        _loading.value = true;

                        if (news.sessionId != null) {
                          Session session =
                              (await Api().sessions().getOne(news.sessionId))!;
                          toWidget = SessionPage(session);
                        } else {
                          Campaign campaign = (await Api()
                              .campaigns()
                              .getOne(news.campaignId))!;
                          toWidget = CampaignPage(campaign);
                        }

                        _loading.value = false;

                        Navigator.push(context,
                            MaterialPageRoute(builder: (c) => toWidget));
                      } catch (e) {
                        print(e);
                        _loading.value = false;

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "Fehler beim Laden der ${news.sessionId != null ? "Session" : "Campaign"}!")));
                      }
                    },
                    trailing: ValueListenableBuilder<bool>(
                        valueListenable: _loading,
                        builder: (context, val, child) {
                          return LoadingIndicator(
                              size: 16, strokeWidth: 3, loading: val);
                        }),
                    leading: RoundedAvatar(
                      news.sessionImgUrl ?? news.campaignImgUrl,
                      blurHash: news.sessionBlurHash ?? news.campaignBlurHash,
                    ),
                    title: AutoSizeText(
                      news.sessionName ?? news.campaignName!,
                      maxLines: 1,
                      style: context.theme.textTheme.bodyText1!
                          .copyWith(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "by ${news.organizationName} - ${timeago.format(news.createdAt)}",
                      style: context.theme.textTheme.caption,
                    )),
            !_showImage
                ? SizedBox.shrink()
                : Container(
                    height: 260,
                    child: VideoOrImage(
                      imageUrl: news.imageUrl,
                      videoUrl: news.videoUrl,
                      blurHash: news.blurHash,
                    ),
                  ),
            _buildExpandableContent()
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableContent() {
    return ExpandableNotifier(
      child: ScrollOnExpand(
        child: Expandable(
          collapsed: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ..._optionalContent(),
              Padding(
                padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: _buildText(),
              ),
              Builder(builder: (context) {
                return _buttonBar(context);
              }),
            ],
          ),
          expanded: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ..._optionalContent(),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: _buildText(true),
              ),
              Builder(builder: (context) {
                return _buttonBar(context);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildText([bool expanded = false]) {
    String text = widget.news.text;

    return FormattedText(text,
        maxLines: expanded
            ? 9999
            : !_showImage
                ? 10
                : 3,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.start,
        style: context.theme.textTheme.bodyText2);
  }

  List<Widget> _optionalContent() {
    List<Widget> widgets = [];
    News news = widget.news;

    if (news.title != null)
      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Text(
            news.title!,
            style: context.theme.textTheme.headline6,
          ),
        ),
      );

    if (news.shortText != null)
      widgets.add(Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
        child: Text(news.shortText!, style: context.theme.textTheme.caption),
      ));

    return widgets;
  }

  Widget _buttonBar(BuildContext context) {
    ExpandableController _controller =
        ExpandableController.of(context, required: true)!;
    return widget.news.text.length >= _maxChars || widget.withDonationButton
        ? ButtonBar(
            alignment: MainAxisAlignment.start,
            children: [
              widget.withDonationButton
                  ? Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6))),
                        onPressed: _donate,
                        child: const Text('UNTERSTÜTZEN'),
                      ),
                    )
                  : SizedBox.shrink(),
              widget.news.text.length >= _maxChars
                  ? TextButton(
                      onPressed: _controller.toggle,
                      child: Text(_controller.expanded ? 'WENIGER' : 'MEHR'),
                    )
                  : SizedBox.shrink(),
            ],
          )
        : SizedBox(
            height: 12,
          );
  }

  Future<void> _donate() async {
    DonationDialog.show(context,
        campaignId: widget.news.campaignId, sessionId: widget.news.sessionId);
  }
}
