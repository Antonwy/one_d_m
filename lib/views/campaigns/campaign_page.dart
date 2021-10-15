import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:one_d_m/components/big_button.dart';
import 'package:one_d_m/components/campaigns/campaign_page_header.dart';
import 'package:one_d_m/components/campaigns/campaign_sessions.dart';
import 'package:one_d_m/components/campaigns/campaign_tags.dart';
import 'package:one_d_m/components/campaigns/campaign_title_and_subscribe.dart';
import 'package:one_d_m/components/discovery_holder.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/components/shuttles/campaign_shuttle.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/helper/helper.dart';
import 'package:one_d_m/helper/numeral.dart';
import 'package:one_d_m/models/campaign_models/base_campaign.dart';
import 'package:one_d_m/models/campaign_models/campaign.dart';
import 'package:one_d_m/provider/campaign_manager.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:one_d_m/views/campaigns/campaign_description.dart';
import 'package:one_d_m/views/campaigns/campaign_news.dart';
import 'package:one_d_m/views/donations/donation_dialog.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

class CampaignPage extends StatefulWidget {
  final BaseCampaign baseCampaign;
  final bool withHero;
  final ScrollController? scrollController;

  const CampaignPage(this.baseCampaign,
      {Key? key, this.scrollController, this.withHero = true})
      : super(key: key);

  @override
  CampaignPageState createState() => CampaignPageState();
}

class CampaignPageState extends State<CampaignPage>
    with SingleTickerProviderStateMixin {
  ScrollController? _scrollController;
  TabController? _tabController;
  Campaign? campaign;

  @override
  void initState() {
    _scrollController = widget.scrollController ?? ScrollController();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);

    context.read<FirebaseAnalytics>().setCurrentScreen(
        screenName: widget.baseCampaign.name == null
            ? "Campaign Page"
            : "${widget.baseCampaign.name} Page");

    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      FeatureDiscovery.discoverFeatures(
          context, DiscoveryHolder.sessionCampaignFeatures);
    });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    return ChangeNotifierProvider<CampaignManager>(
        create: (context) =>
            CampaignManager(widget.baseCampaign, tabController: _tabController),
        builder: (context, child) {
          return HeroMode(
            enabled: widget.withHero,
            child: Hero(
              tag: "${widget.baseCampaign.id}-container",
              flightShuttleBuilder:
                  (flightContext, anim, direction, fromContext, toContext) =>
                      campaignShuttle(anim, direction, fromContext, toContext,
                          _theme, _CampaignPageBottom()),
              child: Scaffold(
                  body: Stack(
                children: [
                  Positioned.fill(
                    child: CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          CampaignPageHeader(),
                          CampaignTitleAndSubscribe(),
                          _CampaignPageBottom()
                        ]),
                  ),
                  Positioned(
                      bottom: 0, right: 0, left: 0, child: _DonationBottom())
                ],
              )),
            ),
          );
        });
  }
}

class _DonationBottom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData _theme = context.theme;
    double bottPad = MediaQuery.of(context).padding.bottom;
    return Container(
      height: bottPad == 0 ? 76 : bottPad + 64,
      child: Material(
        child: Column(
          children: [
            Divider(height: 1.2, thickness: 1.2),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    12, 12, 12, bottPad == 0 ? 12 : bottPad),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.contain,
                        alignment: Alignment.centerLeft,
                        child: Consumer<CampaignManager>(
                            builder: (context, cm, child) {
                          return cm.baseCampaign!.unit?.name != "DVs"
                              ? RichText(
                                  text: TextSpan(
                                      style: _theme.textTheme.bodyText1,
                                      children: [
                                        TextSpan(
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                            text:
                                                "Ein ${cm.baseCampaign!.unit?.singular ?? cm.baseCampaign!.unit?.name ?? "DV"} ${cm.baseCampaign!.unit?.smiley ?? ''}\n"),
                                        TextSpan(text: "entspricht "),
                                        TextSpan(
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                            text:
                                                "${cm.baseCampaign!.unit?.value ?? 1} "),
                                        TextSpan(text: "DVs!"),
                                      ]),
                                )
                              : RichText(
                                  text: TextSpan(
                                      style: _theme.textTheme.bodyText1,
                                      children: [
                                        TextSpan(text: "Unterstütze\n"),
                                        TextSpan(
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                            text: "${cm.baseCampaign!.name}\n"),
                                        TextSpan(text: "schon ab "),
                                        TextSpan(
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                            text: "5 "),
                                        TextSpan(text: "Cent!"),
                                      ]),
                                );
                        }),
                      ),
                    ),
                    XMargin(16),
                    Consumer2<UserManager, CampaignManager>(
                        builder: (context, um, cm, child) =>
                            DiscoveryHolder.donateButton(
                              tapTarget: Icon(
                                Icons.arrow_forward,
                                color: _theme.colorScheme.onPrimary,
                              ),
                              child: BigButton(
                                  color: _theme.colorScheme.secondary,
                                  label: "Unterstützen",
                                  onPressed: (!cm.loadingCampaign!)
                                      ? () {
                                          DonationDialog.show(context,
                                              campaignId: cm.baseCampaign!.id);
                                        }
                                      : () {
                                          Helper.showConnectionSnackBar(
                                              context);
                                        }),
                            ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampaignPageBottom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData _theme = context.theme;
    return MultiSliver(children: [
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        sliver: SliverToBoxAdapter(
          child: Container(
            height: 90,
            child: Consumer<CampaignManager>(
                builder: (context, cm, child) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        _StatCollumn(
                            value: ((cm.baseCampaign?.amount ?? 0.0) /
                                    (cm.baseCampaign?.unit?.value ?? 1.0))
                                .round(),
                            description:
                                "${cm.baseCampaign?.unit?.name ?? "Donation Votes"}"),
                        XMargin(6),
                        _StatCollumn(
                            value: cm.subscribedCount,
                            description: "Mitglieder",
                            isDark: true),
                      ],
                    )),
          ),
        ),
      ),
      SliverToBoxAdapter(child: CampaignTags()),
      SliverToBoxAdapter(
        child: Divider(),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        sliver: SliverToBoxAdapter(
          child: Consumer<CampaignManager>(builder: (context, cm, child) {
            return TabBar(
              controller: cm.tabController,
              indicatorColor: _theme.colorScheme.primary,
              indicatorWeight: 3,
              labelColor: _theme.colorScheme.onBackground,
              unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
              labelStyle: TextStyle(fontWeight: FontWeight.w700),
              tabs: _buildTabs(),
            );
          }),
        ),
      ),
      Consumer<CampaignManager>(builder: (context, cm, child) {
        return SliverPadding(
          padding: const EdgeInsets.only(bottom: 8.0),
          sliver: SliverToBoxAdapter(
            child: AnimatedSize(
              alignment: Alignment.topCenter,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeOut,
              child: [
                CampaignDescription(),
                CampaignNews(),
                CampaignSessions(),
              ][cm.tabIndex!],
            ),
          ),
        );
      }),
      SliverToBoxAdapter(
        child: YMargin(100),
      )
    ]);
  }

  List<Widget> _buildTabs() => [
        Tab(
          text: "Infos",
        ),
        Tab(
          text: "Neuigkeiten",
        ),
        Tab(
          text: "Sessions",
        ),
      ];
}

class _StatCollumn extends StatelessWidget {
  final int? value;
  final String? description;
  final bool isDark;

  _StatCollumn({
    this.value,
    this.description,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = context.theme;
    return Expanded(
      child: Material(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Constants.radius)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AutoSizeText(
              "${Numeral(value ?? 0).value()}",
              textAlign: TextAlign.center,
              maxLines: 1,
              style: _theme.textTheme.headline5!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              description!,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
