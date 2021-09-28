import 'package:flutter/material.dart';
import 'package:one_d_m/components/video_or_image.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/helper/numeral.dart';
import 'package:one_d_m/models/campaign_models/base_campaign.dart';
import 'package:one_d_m/models/donation_unit.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/views/campaigns/campaign_page.dart';
import 'package:one_d_m/views/donations/donation_dialog.dart';
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
    ThemeManager _theme = ThemeManager.of(context);

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
        child: Hero(
          tag: "${widget.campaign.id}-container",
          child: Material(
            elevation: 1,
            color: ColorTheme.appBg,
            borderRadius: BorderRadius.circular(Constants.radius),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    PageRouteBuilder(
                        barrierColor: Colors.black26,
                        pageBuilder: (context, anim1, anim2) => CampaignPage(
                              widget.campaign,
                            ),
                        transitionDuration: Duration(milliseconds: 500),
                        reverseTransitionDuration: Duration(milliseconds: 500),
                        transitionsBuilder: (context, anim1, anim2, child) =>
                            child));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 260,
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(Constants.radius)),
                      child: VideoOrImage(
                        imageUrl: widget.campaign?.imgUrl,
                        videoUrl: widget.campaign?.shortVideoUrl,
                        blurHash: widget.campaign?.blurHash,
                        alwaysMuted: true,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 220,
                              height: 22,
                              child: FittedBox(
                                alignment: Alignment.centerLeft,
                                fit: BoxFit.contain,
                                child: Text(
                                  widget.campaign.name,
                                  style:
                                      _theme.textTheme.dark.bodyText1.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            MaterialButton(
                                color: _theme.colors.dark,
                                height: 30,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24)),
                                onPressed: () async {
                                  await _donate(context, widget.campaign);
                                },
                                elevation: 0,
                                highlightElevation: 1,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                child: Text(
                                  "Unterstützen",
                                  style: _theme.textTheme.textOnDark.bodyText1
                                      .copyWith(
                                    fontSize: 11,
                                  ),
                                )),
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
                                  for (String tag
                                      in widget.campaign?.tags ?? [])
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
