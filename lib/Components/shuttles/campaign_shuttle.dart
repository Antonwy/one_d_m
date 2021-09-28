import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/components/video_or_image.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/helper/numeral.dart';
import 'package:one_d_m/models/campaign_models/base_campaign.dart';
import 'package:one_d_m/models/donation_unit.dart';
import 'package:one_d_m/provider/campaign_manager.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/views/home/profile_page.dart';
import 'package:provider/provider.dart';

import '../campaign_header.dart';
import '../donation_widget.dart';
import '../margin.dart';

Widget _buttonShuttle(
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
    ThemeManager _theme) {
  CampaignManager cm = (flightDirection == HeroFlightDirection.push
          ? toHeroContext
          : fromHeroContext)
      .read<CampaignManager>();

  double borderRadius = Tween<double>(begin: 24, end: 6).evaluate(animation);

  double opacity = TweenSequence([
    TweenSequenceItem(tween: Tween<double>(begin: 1, end: 0), weight: 1),
    TweenSequenceItem(tween: Tween<double>(begin: 0, end: 1), weight: 1)
  ]).evaluate(animation);

  int show = IntTween(begin: 0, end: 1).evaluate(animation);

  Color toColor =
      (cm?.subscribed ?? false) ? _theme.colors.contrast : _theme.colors.dark;
  Color color = ColorTween(
    begin: _theme.colors.dark,
    end: toColor,
  ).evaluate(animation);

  Color toTextColor = (cm?.subscribed ?? false)
      ? _theme.colors.textOnContrast
      : _theme.colors.textOnDark;
  Color textColor = ColorTween(
    begin: _theme.colors.textOnDark,
    end: toTextColor,
  ).evaluate(animation);

  return ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius),
    child: Container(
      height: Tween<double>(begin: 30, end: 36).evaluate(animation),
      child: MaterialButton(
          onPressed: () {},
          color: color,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          child: Opacity(
            opacity: opacity,
            child: Center(
              child: AnimatedSize(
                duration: Duration(milliseconds: 125),
                child: Text(
                  show == 1
                      ? (cm?.subscribed ?? false)
                          ? "Verlassen"
                          : "Beitreten"
                      : "Unterstützen",
                  style: show == 1
                      ? _theme.textTheme
                          .withColor(textColor)
                          .bodyText2
                          .copyWith(fontSize: 13, fontWeight: FontWeight.w600)
                      : _theme.textTheme
                          .withColor(textColor)
                          .bodyText1
                          .copyWith(
                            fontSize: 11,
                          ),
                ),
              ),
            ),
          )),
    ),
  );
}

Widget _titleShuttle(
    String title, Animation<double> animation, ThemeManager _theme) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      return Container(
        width: 220,
        height: Tween<double>(begin: 22.0, end: 30.0).evaluate(animation),
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: _theme.textTheme.dark.bodyText1
                .copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      );
    },
  );
}

String getFirstTag(BaseCampaign campaign) {
  DonationUnit unit = campaign.unit ?? DonationUnit.defaultUnit;
  return "${Numeral(((campaign?.amount ?? 0) / (unit.value)).round()).value()} ${unit.name} ${unit.effect}";
}

Widget campaignShuttle(
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
    ThemeManager _theme,
    Widget bottomWidget) {
  CampaignManager cm = (flightDirection == HeroFlightDirection.push
          ? toHeroContext
          : fromHeroContext)
      .read<CampaignManager>();

  BaseCampaign campaign = cm.baseCampaign;

  return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        Animation curvedAnim =
            CurvedAnimation(parent: animation, curve: Interval(.8, 1.0));
        return Material(
          elevation: 1,
          color: ColorTheme.appBg,
          borderRadius: BorderRadius.circular(Constants.radius),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Stack(
                      children: [
                        Container(
                          height: Tween<double>(
                                  begin: 260,
                                  end: MediaQuery.of(context).size.width)
                              .evaluate(animation),
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(Constants.radius)),
                            child: VideoOrImage(
                              imageUrl: campaign?.imgUrl,
                              videoUrl: campaign?.shortVideoUrl,
                              blurHash: campaign?.blurHash,
                              alwaysMuted: true,
                            ),
                          ),
                        ),
                        Positioned(
                          top: Tween<double>(
                                  begin: 12,
                                  end: MediaQuery.of(context).padding.top)
                              .evaluate(animation),
                          right: 12,
                          left: 12,
                          child: FadeTransition(
                            opacity: CurvedAnimation(
                                parent: animation, curve: Interval(.8, 1.0)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppBarButton(
                                    elevation: 10, icon: Icons.arrow_back),
                                Row(
                                  children: [
                                    AppBarButton(
                                      icon: CupertinoIcons.share,
                                      elevation: 10,
                                    ),
                                    XMargin(6),
                                    AppBarButton(
                                      elevation: 10,
                                      child: RoundedAvatar(
                                        cm.campaign?.organization
                                                ?.thumbnailUrl ??
                                            cm.campaign?.organization?.imgUrl,
                                        height: 15,
                                        color: ColorTheme.appBg,
                                        backgroundLight: true,
                                        loading: cm.loadingCampaign,
                                        fit: BoxFit.contain,
                                        borderRadius: 6,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
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
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _titleShuttle(
                                      campaign.name, animation, _theme),
                                  SizeTransition(
                                    axisAlignment: flightDirection ==
                                            HeroFlightDirection.push
                                        ? 1
                                        : -1,
                                    sizeFactor:
                                        Tween<double>(begin: 0.0, end: 1.0)
                                            .animate(animation),
                                    child: SizedBox(
                                      height: 17,
                                      child: FadeTransition(
                                        opacity: animation,
                                        child: RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(text: 'by '),
                                              TextSpan(
                                                  text:
                                                      '${cm?.campaign?.organization?.name ?? 'Laden...'}',
                                                  style: _theme
                                                      .textTheme.dark.bodyText1
                                                      .copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    decoration: TextDecoration
                                                        .underline,
                                                  )),
                                            ],
                                            style: _theme.textTheme.dark
                                                .withOpacity(.54)
                                                .bodyText1
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.w400),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                              _buttonShuttle(animation, flightDirection,
                                  fromHeroContext, toHeroContext, _theme)
                            ],
                          ),
                          YMargin(Tween<double>(begin: 8.0, end: 0)
                              .evaluate(animation)),
                          FadeTransition(
                            opacity: CurvedAnimation(
                                parent: animation
                                    .drive(Tween<double>(begin: 1.0, end: 0.0)),
                                curve: Interval(.8, 1.0),
                                reverseCurve: Interval(.8, 1.0)),
                            child: SizeTransition(
                              axisAlignment: -1,
                              sizeFactor: CurvedAnimation(
                                  parent: animation.drive(
                                      Tween<double>(begin: 1.0, end: 0.0)),
                                  curve: Interval(.8, 1.0),
                                  reverseCurve: Interval(.8, 1.0)),
                              child: campaign.tags == null
                                  ? Text("${campaign?.shortDescription ?? ""}")
                                  : Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: [
                                        CampaignTag(
                                            text: getFirstTag(campaign),
                                            color: _theme.colors.dark,
                                            textColor: _theme.colors.textOnDark,
                                            icon: Icons.info,
                                            bold: true),
                                        for (String tag in campaign?.tags ?? [])
                                          if (tag.isNotEmpty)
                                            CampaignTag(text: tag)
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        child: FadeTransition(
                      opacity: CurvedAnimation(
                          parent: animation, curve: Interval(.5, 1.0)),
                      child: CustomScrollView(slivers: [
                        ChangeNotifierProvider(
                          create: (context) => cm.copyCM(),
                          builder: (context, child) => bottomWidget,
                        )
                      ]),
                    ))
                  ],
                ),
              ),
              Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SlideTransition(
                    position:
                        Tween<Offset>(begin: Offset(0, 1), end: Offset.zero)
                            .animate(curvedAnim),
                    child: FadeTransition(
                        opacity: curvedAnim,
                        child: _DonationBottomPlaceholder(cm)),
                  ))
            ],
          ),
        );
      });
}

class _DonationBottomPlaceholder extends StatelessWidget {
  final CampaignManager cm;

  const _DonationBottomPlaceholder(this.cm);

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    double bottPad = MediaQuery.of(context).padding.bottom;
    return Container(
      height: bottPad == 0 ? 76 : bottPad + 64,
      color: _theme.colors.contrast,
      child: Column(
        children: [
          Divider(height: 1.2, thickness: 1.2),
          Expanded(
            child: Padding(
              padding:
                  EdgeInsets.fromLTRB(12, 12, 12, bottPad == 0 ? 12 : bottPad),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      alignment: Alignment.centerLeft,
                      child: cm.baseCampaign.unit.name != "DVs"
                          ? RichText(
                              text: TextSpan(
                                  style:
                                      _theme.textTheme.textOnContrast.bodyText1,
                                  children: [
                                    TextSpan(
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                        text:
                                            "Ein ${cm.baseCampaign.unit.singular ?? cm.baseCampaign.unit.name} ${cm.baseCampaign.unit.smiley ?? ''}\n"),
                                    TextSpan(text: "entspricht "),
                                    TextSpan(
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                        text: "${cm.baseCampaign.unit.value} "),
                                    TextSpan(text: "DVs!"),
                                  ]),
                            )
                          : RichText(
                              text: TextSpan(
                                  style:
                                      _theme.textTheme.textOnContrast.bodyText1,
                                  children: [
                                    TextSpan(text: "Unterstütze\n"),
                                    TextSpan(
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                        text: "${cm.baseCampaign.name}\n"),
                                    TextSpan(text: "schon ab "),
                                    TextSpan(
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                        text: "5 "),
                                    TextSpan(text: "Cent!"),
                                  ]),
                            ),
                    ),
                  ),
                  XMargin(16),
                  FloatingActionButton.extended(
                      heroTag: null,
                      backgroundColor: _theme.colors.dark,
                      label: Text("Unterstützen",
                          style: TextStyle(color: _theme.colors.textOnDark)),
                      onPressed: () {})
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
