import 'package:flutter/material.dart';
import 'package:one_d_m/components/empty.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/components/sessions/session_view.dart';
import 'package:one_d_m/models/session_models/base_session.dart';
import 'package:one_d_m/provider/campaign_manager.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:provider/provider.dart';

import '../margin.dart';

class CampaignSessions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CampaignManager cm = context.watch<CampaignManager>();

    if (cm.loadingCampaign)
      return SliverToBoxAdapter(
        child: LoadingIndicator(message: "Lade Sessions des Projekts"),
      );

    if (cm.campaign.sessions.isEmpty)
      return SliverToBoxAdapter(
        child:
            Empty(message: "Es existieren keine Sessions für dieses Projekt"),
      );

    List<BaseSession> sessions = cm.campaign.sessions;

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Text(
                '${sessions.length} Influencer engagieren sich für dieses Projekt.',
                style: ThemeManager.of(context).textTheme.dark.bodyText1),
          ),
          const YMargin(8),
          Container(
            height: 180,
            child: ListView.separated(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                separatorBuilder: (context, index) => SizedBox(
                      width: 8,
                    ),
                itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.only(
                          left: index == 0 ? 12.0 : 0.0,
                          right: index == sessions.length - 1 ? 12.0 : 0.0),
                      child: SessionView(sessions[index]),
                    ),
                itemCount: sessions.length),
          ),
        ],
      ),
    );
  }
}
