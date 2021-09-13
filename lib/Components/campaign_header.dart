import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:one_d_m/components/video_or_image.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/helper/numeral.dart';
import 'package:one_d_m/models/campaign_models/base_campaign.dart';
import 'package:one_d_m/models/campaign_models/campaign.dart';
import 'package:one_d_m/models/donation_unit.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:one_d_m/utils/video/video_widget.dart';
import 'package:one_d_m/views/campaigns/campaign_page.dart';
import 'package:one_d_m/views/donations/donation_dialog.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'bottom_dialog.dart';
import 'margin.dart';

class CampaignHeader extends StatefulWidget {
  final BaseCampaign campaign;
  bool isInView;

  CampaignHeader({
    Key key,
    this.campaign,
    this.isInView = false,
  }) : super(key: key);

  @override
  _CampaignHeaderState createState() => _CampaignHeaderState();
}

class _CampaignHeaderState extends State<CampaignHeader> {
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ThemeManager _theme = ThemeManager.of(context);

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
        child: Material(
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(Constants.radius),
          elevation: 1,
          child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CampaignPage(widget.campaign)));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 260,
                  child: VideoOrImage(
                    imageUrl: widget.campaign?.imgUrl,
                    videoUrl: widget.campaign?.shortVideoUrl,
                    blurHash: widget.campaign?.blurHash,
                    alwaysMuted: true,
                  ),
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
                          )),
                          XMargin(12),
                          Material(
                              clipBehavior: Clip.antiAlias,
                              color: _theme.colors.dark,
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
                                    style: _theme.textTheme.textOnDark.bodyText1
                                        .copyWith(
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ))
                        ],
                      ),
                      YMargin(8),
                      widget.campaign.tags == null
                          ? Text("${widget.campaign?.shortDescription ?? ""}")
                          : Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                CampaignTag(
                                    text: getFirstTag(),
                                    color: _theme.colors.dark,
                                    textColor: _theme.colors.textOnDark,
                                    icon: Icons.info,
                                    bold: true),
                                for (String tag in widget.campaign?.tags ?? [])
                                  if (tag.isNotEmpty) CampaignTag(text: tag)
                              ],
                            ),
                      // widget.campaign.shortDescription == null
                      //     ? Container()
                      //     : Text(widget.campaign.shortDescription),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  String getFirstTag() {
    DonationUnit unit = widget.campaign.unit ?? DonationUnit.defaultUnit;
    return "${Numeral(((widget.campaign?.amount ?? 0) / (unit.value)).round()).value()} ${unit.name} ${unit.effect}";
  }

  Future<void> _donate(BuildContext context, BaseCampaign campaign) async {
    await DonationDialog.show(context,
        campaignId: campaign.id, donationEffects: campaign.donationEffects);
  }
}

class CampaignTag extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color, textColor;
  final bool bold;

  const CampaignTag(
      {Key key,
      this.text,
      this.icon,
      this.color,
      this.textColor,
      this.bold = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
        child: icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: textColor,
                    size: 14,
                  ),
                  XMargin(6),
                  Text(
                    text,
                    style: TextStyle(
                        color:
                            textColor ?? ThemeManager.of(context).colors.dark,
                        fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 12),
                  )
                ],
              )
            : Text(
                text,
                style: TextStyle(
                    color: textColor ?? ThemeManager.of(context).colors.dark,
                    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12),
              ),
      ),
      color: color ?? ThemeManager.of(context).colors.contrast.withOpacity(.5),
    );
  }
}
