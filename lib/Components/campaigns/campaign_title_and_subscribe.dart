import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/components/custom_open_container.dart';
import 'package:one_d_m/components/join_button.dart';
import 'package:one_d_m/models/campaign_models/base_campaign.dart';
import 'package:one_d_m/provider/campaign_manager.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:one_d_m/views/campaigns/create_post.dart';
import 'package:one_d_m/views/organizations/organization_page.dart';
import 'package:provider/provider.dart';

class CampaignTitleAndSubscribe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CampaignManager cm = context.watch<CampaignManager>();
    ThemeManager _theme = ThemeManager.of(context);

    return SliverPadding(
      padding: const EdgeInsets.all(12.0),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      width: 220,
                      height: 30,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          cm.baseCampaign?.name ?? "Laden...",
                          maxLines: 1,
                          style: _theme.textTheme.dark.bodyText1
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      )),
                  InkWell(
                    onTap: cm.loadingCampaign
                        ? null
                        : () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OrganizationPage(
                                        cm.campaign.organization)));
                          },
                    child: RichText(
                      maxLines: 1,
                      text: TextSpan(
                        children: [
                          TextSpan(text: 'by '),
                          TextSpan(
                              text:
                                  '${cm.campaign?.organization?.name ?? 'Laden...'}',
                              style: _theme.textTheme.dark.bodyText1.copyWith(
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              )),
                        ],
                        style: _theme.textTheme.dark
                            .withOpacity(.54)
                            .bodyText1
                            .copyWith(fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Consumer<UserManager>(builder: (context, um, child) {
              return um.uid == cm.baseCampaign?.adminId &&
                      cm.baseCampaign?.adminId != null &&
                      (cm.baseCampaign?.adminId?.isNotEmpty ?? false)
                  ? _createPostButton(_theme, cm.baseCampaign)
                  : Builder(builder: (context) {
                      return JoinButton(
                          joinOrLeave: cm.loadingCampaign
                              ? null
                              : (val) => cm.leaveOrJoinCampaign(val, context),
                          subscribed: cm.subscribed);
                    });
            }),
          ],
        ),
      ),
    );
  }

  Widget _createPostButton(ThemeManager _theme, BaseCampaign baseCampaign) =>
      CustomOpenContainer(
        closedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        closedElevation: 0,
        openBuilder: (context, close, scrollController) => CreatePostScreen(
          isSession: false,
          campaign: baseCampaign,
          controller: scrollController,
        ),
        closedColor: Colors.transparent,
        closedBuilder: (context, open) => RaisedButton(
            color: _theme.colors.dark,
            textColor: _theme.colors.textOnDark,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            child: AutoSizeText("Post erstellen", maxLines: 1),
            onPressed: open),
      );
}
