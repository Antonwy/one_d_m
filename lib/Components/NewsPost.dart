import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/BottomDialog.dart';
import 'package:one_d_m/Components/DonationDialogWidget.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/utils/video/video_widget.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:visibility_detector/visibility_detector.dart';

import 'CampaignButton.dart';

class NewsPost extends StatefulWidget {
  final News news;
  final bool withCampaign, withDonationButton;
  bool isInView;
  final VoidCallback onPostSeen;

  NewsPost(this.news,
      {this.withCampaign = true,
      this.isInView = false,
      this.withDonationButton = false,
      this.onPostSeen});

  @override
  _NewsPostState createState() => _NewsPostState();
}

class _NewsPostState extends State<NewsPost> {
  bool _muted = true;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.news.id),
      onVisibilityChanged: (VisibilityInfo info) {
        var visiblePercentage = info.visibleFraction * 100;
        if (mounted) {
          if (visiblePercentage == 100) {
            widget.onPostSeen();
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
              widget.withCampaign
                  ? CampaignButton(
                      widget.news.campaignId,
                      borderRadius: 0,
                      textStyle: TextStyle(),
                      campaign: Campaign(
                          imgUrl: widget.news.campaignImgUrl,
                          id: widget.news.campaignId,
                          name: widget.news.campaignName),
                    )
                  : Container(),
              Container(
                child: Stack(
                  children: <Widget>[
                    widget.news.videoUrl != null
                        ? VideoWidget(
                            url: widget.news.videoUrl,
                            play: widget.isInView,
                            imageUrl: widget.news.videoUrl,
                            muted: _muted,
                            toggleMuted: _toggleMuted,
                          )
                        : CachedNetworkImage(
                            width: double.infinity,
                            height: 260,
                            imageUrl: widget.news.imageUrl ?? '',
                            errorWidget: (_, __, ___) => Container(
                              height: 260,
                              child: Center(
                                  child: Icon(
                                Icons.error,
                                color: ColorTheme.orange,
                              )),
                            ),
                            placeholder: (context, url) => Container(
                              height: 260,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            fit: BoxFit.fill,
                          ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                Colors.black.withOpacity(.7),
                                Colors.black.withOpacity(0)
                              ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter)),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            widget.news?.videoUrl != null
                                ? MuteButton(
                                    muted: _muted,
                                    toggle: _toggleMuted,
                                  )
                                : SizedBox.shrink(),
                            Text(
                              timeago.format(widget.news.createdAt,
                                  locale: "de"),
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    widget.news.userId?.isNotEmpty ?? false
                        ? _buildCreatorTitle(widget.news.userId)
                        : const SizedBox.shrink(),
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

  void _toggleMuted() {
    setState(() {
      _muted = !_muted;
    });
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
    BottomDialog bd = BottomDialog(context);
    UserManager um = context.read<UserManager>();
    bd.show(DonationDialogWidget(
      campaign: await DatabaseService.getCampaign(widget.news.campaignId),
      user: um.user,
      context: context,
      close: bd.close,
      sessionId: widget.news.sessionId.isEmpty ? null : widget.news.sessionId,
      uid: um.uid,
    ));
  }

  Widget _buildCreatorTitle(String uid) => StreamBuilder(
        stream: DatabaseService.getUserStream(uid),
        builder: (context, AsyncSnapshot<User> snapshot) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 0, 0),
            child: Text('@${snapshot.data?.name ?? 'Laden...'}',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: ThemeManager.of(context).colors.dark)),
          );
        },
      );
}
