import 'package:flutter/material.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/api/stream_result.dart';
import 'package:one_d_m/components/campaigns/campaign_header.dart';
import 'package:one_d_m/components/donation_widget.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/models/campaign_models/base_campaign.dart';
import 'package:one_d_m/models/organization.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class OrganizationPage extends StatelessWidget {
  Organization? organization;
  late ThemeData _theme;
  ScrollController? scrollController;

  OrganizationPage(this.organization, {this.scrollController});

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: _theme.backgroundColor,
            title: Text(
              organization!.name!,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    child: RoundedAvatar(
                      organization?.imgUrl,
                      elevation: 1,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    organization?.description ?? "",
                    style: _theme.textTheme.caption,
                    textAlign: TextAlign.center,
                  ),
                  organization?.website == null
                      ? SizedBox(
                          height: 12,
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: OutlinedButton(
                            child: Text("Mehr Informationen"),
                            onPressed: () async {
                              if (await canLaunch(organization!.website!)) {
                                launch(organization!.website!);
                              }
                            },
                          ),
                        ),
                  Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "Projekte dieser Organisation:",
                        style: _theme.textTheme.headline6,
                      )),
                ],
              ),
            ),
          ),
          StreamBuilder<StreamResult<List<BaseCampaign?>>>(
              stream: Api()
                  .campaigns()
                  .organizationId(organization?.id)
                  .streamGet(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return SliverToBoxAdapter(
                    child: Center(
                        child: Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: LoadingIndicator(message: "Lade Projekte"))),
                  );

                if (snapshot.data!.data?.isEmpty ?? true)
                  return SliverToBoxAdapter(
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child:
                          Text("Diese Organisation hat noch keine Campagnen."),
                    )),
                  );
                return SliverPadding(
                  padding: const EdgeInsets.only(bottom: 24),
                  sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                          (context, index) => CampaignHeader(
                              campaign: snapshot.data!.data![index]!,
                              withHero: false),
                          childCount: snapshot.data!.data!.length)),
                );
              })
        ],
      ),
    );
  }
}
