import 'package:flutter/material.dart';
import 'package:one_d_m/components/join_button.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:one_d_m/provider/campaign_manager.dart';
import 'package:one_d_m/views/organizations/organization_page.dart';
import 'package:provider/provider.dart';

class CampaignTitleAndSubscribe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CampaignManager cm = context.watch<CampaignManager>();
    ThemeData _theme = Theme.of(context);

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
                          style: _theme.textTheme.bodyText1!
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      )),
                  InkWell(
                    onTap: cm.loadingCampaign!
                        ? null
                        : () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OrganizationPage(
                                        cm.campaign!.organization)));
                          },
                    child: RichText(
                      maxLines: 1,
                      text: TextSpan(
                        children: [
                          TextSpan(text: 'by '),
                          TextSpan(
                              text:
                                  '${cm.campaign?.organization.name ?? 'Laden...'}',
                              style: _theme.textTheme.bodyText1!.copyWith(
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              )),
                        ],
                        style: _theme.textTheme.bodyText1!
                            .withOpacity(.54)
                            .copyWith(fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            JoinButton(
                joinOrLeave: cm.loadingCampaign!
                    ? null
                    : (val) => cm.leaveOrJoinCampaign(val, context),
                subscribed: cm.subscribed)
          ],
        ),
      ),
    );
  }
}
