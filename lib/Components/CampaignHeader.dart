import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:one_d_m/Pages/NewCampaignPage.dart';
import 'package:one_d_m/utils/video/video_widget.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'BottomDialog.dart';
import 'CustomOpenContainer.dart';
import 'DonationDialogWidget.dart';

class CampaignHeader extends StatefulWidget {
  final Campaign campaign;
  bool isInView;

  CampaignHeader({
    Key key,
    this.campaign,
    this.isInView = false,
  }) : super(key: key);

  @override
  _CampaignHeaderState createState() => _CampaignHeaderState();
}

class _CampaignHeaderState extends State<CampaignHeader>{
  bool _muted = true;

  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ThemeManager _theme = ThemeManager.of(context);

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
        child: CustomOpenContainer(
          closedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.radius)),
          closedElevation: 1,
          openBuilder: (context, close, scrollController) {
              widget.isInView = false;
            return NewCampaignPage(
                widget.campaign,
                scrollController: scrollController);
          },
          closedColor: ColorTheme.appBg,
          closedBuilder: (context, open) => VisibilityDetector(
            key: Key(widget.campaign.id),
            onVisibilityChanged: (VisibilityInfo info) {
              var visiblePercentage = (info.visibleFraction) * 100;
              if (mounted) {
                if (visiblePercentage == 100) {
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
            child: InkWell(
              onTap: open,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    children: [
                      widget.campaign.shortVideoUrl != null
                          ? VideoWidget(
                        url: widget.campaign.shortVideoUrl,
                        play: widget.isInView,
                        imageUrl: widget.campaign.shortVideoUrl,
                        muted: _muted,
                        toggleMuted: _toggleMuted,
                      )
                          : CachedNetworkImage(
                        imageUrl: widget.campaign.imgUrl,
                        height: 260,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Center(
                            child: Icon(
                              Icons.error,
                              color: ColorTheme.orange,
                            )),
                        alignment: Alignment.center,
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
                              widget.campaign?.shortVideoUrl != null
                                  ? MuteButton(
                                muted: _muted,
                                toggle: _toggleMuted,
                              )
                                  : SizedBox.shrink(),
                              SizedBox.shrink(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            Expanded(
                              child: AutoSizeText(
                                widget.campaign.name,
                                style: textTheme.headline6,
                                maxLines: 1,
                              ),
                            ),
                            XMargin(12),
                            Material(
                                clipBehavior: Clip.antiAlias,
                                color: _theme.colors.contrast.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  onTap: () async {
                                    await _donate(context, widget.campaign);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 12),
                                    child: Text(
                                      "Unterstützen",
                                      style: _theme.textTheme.dark.bodyText1
                                          .copyWith(
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ))
                          ],
                        ),
                        YMargin(8),
                        widget.campaign.shortDescription == null
                            ? Container()
                            : Text(widget.campaign.shortDescription),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  void _toggleMuted() {
    setState(() {
      _muted = !_muted;
    });
  }

  Future<void> _donate(BuildContext context, Campaign campaign) async {
    BottomDialog bd = BottomDialog(context);
    UserManager um = context.read<UserManager>();
    return bd.show(DonationDialogWidget(
      campaign: campaign,
      user: um.user,
      context: context,
      close: bd.close,
      uid: um.uid,
    ));
  }
}
