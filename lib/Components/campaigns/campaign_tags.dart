import 'package:flutter/material.dart';
import 'package:one_d_m/components/campaign_header.dart';
import 'package:one_d_m/provider/campaign_manager.dart';
import 'package:provider/provider.dart';

class CampaignTags extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CampaignManager>(builder: (context, cm, child) {
      List<String> tags = cm.baseCampaign?.tags ?? [];
      return tags.isNotEmpty && tags.where((el) => el.isNotEmpty).isNotEmpty
          ? Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (String tag in tags)
                    if (tag.isNotEmpty) CampaignTag(text: tag)
                ],
              ),
            )
          : SizedBox.shrink();
    });
  }
}
