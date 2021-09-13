import 'package:flutter/material.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/models/campaign_models/base_campaign.dart';
import 'package:one_d_m/provider/campaign_manager.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:provider/provider.dart';

class CampaignDescription extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BaseCampaign campaign = context.read<CampaignManager>().baseCampaign;
    ThemeManager _theme = ThemeManager.of(context);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              campaign?.shortDescription ?? '',
              style: _theme.textTheme.dark.bodyText1
                  .copyWith(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            YMargin(6),
            Text(
              campaign?.description ?? '',
              style: _theme.textTheme.dark.bodyText2
                  .copyWith(fontWeight: FontWeight.w400),
            ),
            YMargin(6),
            campaign?.effects != null &&
                    campaign.effects.isNotEmpty &&
                    campaign.effects.where((el) => el.isNotEmpty).length > 0
                ? Text(
                    "Was dieses Projekt bewirkt:",
                    style: _theme.textTheme.dark.bodyText1
                        .copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                  )
                : SizedBox.shrink(),
            YMargin(6),
            for (String effect in campaign?.effects ?? [])
              if (effect.isNotEmpty)
                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('•'),
                        XMargin(6),
                        Expanded(
                          child: Text(
                            '$effect',
                            style: _theme.textTheme.dark.bodyText1.copyWith(
                                fontSize: 15, fontWeight: FontWeight.w400),
                          ),
                        ),
                      ],
                    ),
                    YMargin(6),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}
