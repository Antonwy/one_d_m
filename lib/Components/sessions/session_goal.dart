import 'package:flutter/material.dart';
import 'package:one_d_m/components/info_feed.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/helper/numeral.dart';
import 'package:one_d_m/models/campaign_models/base_campaign.dart';
import 'package:one_d_m/models/campaign_models/campaign.dart';
import 'package:one_d_m/models/session_models/base_session.dart';
import 'package:one_d_m/models/session_models/session.dart';
import 'package:one_d_m/provider/sessions_manager.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/views/campaigns/campaign_page.dart';
import 'package:provider/provider.dart';

class SessionGoal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BaseSessionManager sm = context.watch<BaseSessionManager>();
    ThemeManager _theme = ThemeManager.of(context);
    BaseSession baseSession = sm?.baseSession;
    return SliverToBoxAdapter(
      child: (baseSession?.donationGoal ?? 0) > 0
          ? Builder(builder: (context) {
              Color textColor =
                  _theme.correctColorFor(sm.baseSession.secondaryColor);
              BaseTextTheme textTheme = _theme.textTheme
                  .correctColorFor(sm.baseSession.secondaryColor);

              if (!sm.loadingMoreInfo) baseSession = sm.session;
              String _unit = sm.unit.name;
              String _smiley = sm.unit.smiley;

              double amount = sm.baseSession.amount / sm.unit.value;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                      color: baseSession.secondaryColor,
                      borderRadius: BorderRadius.circular(Constants.radius),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                                child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                            text:
                                                "${Numeral(amount).value()} "),
                                        if (_smiley != null)
                                          TextSpan(
                                              text: "$_smiley",
                                              style: TextStyle(
                                                  fontSize: 38,
                                                  fontWeight: FontWeight.w300))
                                        else
                                          TextSpan(
                                              text: _unit ?? "DVs",
                                              style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w300))
                                      ],
                                      style: textTheme.headline5.copyWith(
                                          fontSize: 38,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  YMargin(8),
                                  _SessionGoalCampaign()
                                ],
                              ),
                            )),
                            YMargin(6),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6.0),
                              child: LayoutBuilder(
                                  builder: (context, constraints) {
                                return Container(
                                  width: constraints.maxWidth,
                                  child: PercentLine(
                                    percent: (amount / baseSession.donationGoal)
                                        .clamp(0.0, 1.0),
                                    height: 10.0,
                                    color: textColor,
                                  ),
                                );
                              }),
                            ),
                            YMargin(6.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${_formatPercent(baseSession)}% erreicht",
                                  style: textTheme.bodyText1,
                                ),
                                RichText(
                                    text: TextSpan(
                                        style: textTheme.bodyText1.copyWith(
                                            fontWeight: FontWeight.w400),
                                        children: [
                                      TextSpan(
                                        text: "Ziel: ",
                                      ),
                                      TextSpan(
                                          text: "${baseSession.donationGoal} ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(
                                          text: "${_smiley ?? _unit ?? "DV"}"),
                                    ])),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            })
          : SizedBox.shrink(),
    );
  }

  String _formatPercent(BaseSession baseSession) {
    double percentValue =
        ((baseSession.amount / baseSession.donationUnit.value) /
                baseSession.donationGoal) *
            100;

    if (percentValue < 1) return percentValue.toStringAsFixed(2);
    if ((percentValue % 1) == 0) return percentValue.toInt().toString();

    return percentValue.toStringAsFixed(1);
  }
}

class _SessionGoalCampaign extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    BaseSessionManager sm = context.watch<BaseSessionManager>();

    Color textColor = _theme.correctColorFor(sm.baseSession.secondaryColor);
    BaseTextTheme textTheme =
        _theme.textTheme.correctColorFor(sm.baseSession.secondaryColor);

    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: textColor)),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: !sm.loadingMoreInfo
              ? () {
                  Session s = sm.session;
                  BaseCampaign _campaign = BaseCampaign(
                    id: s.campaignId,
                    name: s.campaignTitle,
                    shortDescription: s.campaignShortDescription,
                    imgUrl: s.campaignImageUrl,
                    thumbnailUrl: s.campaignThumbnailUrl,
                  );
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CampaignPage(_campaign)));
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12),
            child: Text(sm.campaignName(), style: textTheme.bodyText1),
          ),
        ),
      ),
    );
  }
}
