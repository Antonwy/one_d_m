import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:one_d_m/components/campaigns/campaign_page_header.dart';
import 'package:one_d_m/components/campaigns/campaign_sessions.dart';
import 'package:one_d_m/components/campaigns/campaign_tags.dart';
import 'package:one_d_m/components/campaigns/campaign_title_and_subscribe.dart';
import 'package:one_d_m/components/discovery_holder.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/helper/helper.dart';
import 'package:one_d_m/helper/numeral.dart';
import 'package:one_d_m/models/campaign_models/base_campaign.dart';
import 'package:one_d_m/models/campaign_models/campaign.dart';
import 'package:one_d_m/provider/campaign_manager.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:one_d_m/views/campaigns/campaign_description.dart';
import 'package:one_d_m/views/campaigns/campaign_news.dart';
import 'package:one_d_m/views/donations/donation_dialog.dart';
import 'package:provider/provider.dart';

class CampaignPage extends StatefulWidget {
  BaseCampaign baseCampaign;
  ScrollController scrollController;

  CampaignPage(this.baseCampaign, {Key key, this.scrollController})
      : super(key: key);

  @override
  CampaignPageState createState() => CampaignPageState();
}

class CampaignPageState extends State<CampaignPage>
    with SingleTickerProviderStateMixin {
  TextTheme _textTheme;
  BaseTheme _bTheme;
  ScrollController _scrollController;
  TabController _tabController;
  Campaign campaign;

  @override
  void initState() {
    _scrollController = widget.scrollController ?? ScrollController();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);

    context.read<FirebaseAnalytics>().setCurrentScreen(
        screenName: widget.baseCampaign?.name == null
            ? "Campaign Page"
            : "${widget.baseCampaign.name} Page");

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
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
    _textTheme = Theme.of(context).textTheme;
    _bTheme = ThemeManager.of(context).colors;
    return ChangeNotifierProvider<CampaignManager>(
        create: (context) =>
            CampaignManager(widget.baseCampaign, tabController: _tabController),
        builder: (context, child) {
          return Scaffold(
              backgroundColor: ColorTheme.appBg,
              floatingActionButton: OfflineBuilder(
                  child: Container(),
                  connectivityBuilder: (context, connection, child) {
                    bool activated = connection != ConnectivityResult.none;
                    return Consumer2<UserManager, CampaignManager>(
                        builder: (context, um, cm, child) =>
                            DiscoveryHolder.donateButton(
                              tapTarget: Icon(
                                Icons.arrow_forward,
                                color: _bTheme.contrast,
                              ),
                              child: FloatingActionButton.extended(
                                  backgroundColor:
                                      activated ? _bTheme.dark : Colors.grey,
                                  label: Text("Unterstützen",
                                      style:
                                          TextStyle(color: _bTheme.textOnDark)),
                                  onPressed: !cm.loadingCampaign && activated
                                      ? () {
                                          DonationDialog.show(context,
                                              campaignId:
                                                  widget.baseCampaign.id);
                                        }
                                      : () {
                                          Helper.showConnectionSnackBar(
                                              context);
                                        }),
                            ));
                  }),
              body: CustomScrollView(controller: _scrollController, slivers: [
                CampaignPageHeader(),
                CampaignTitleAndSubscribe(),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      height: 90,
                      child: Consumer<CampaignManager>(
                          builder: (context, cm, child) => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  _StatCollumn(
                                      value: ((cm.baseCampaign?.amount ?? 0.0) /
                                              (cm.baseCampaign?.unit?.value ??
                                                  1.0))
                                          .round(),
                                      description:
                                          "${cm.baseCampaign?.unit?.name ?? "Donation Votes"}"),
                                  XMargin(6),
                                  _StatCollumn(
                                      value: cm.subscribedCount,
                                      description: "Abonnenten",
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
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: _bTheme.contrast,
                      indicatorWeight: 3,
                      labelColor: _bTheme.dark,
                      unselectedLabelColor: _bTheme.dark.withOpacity(.5),
                      unselectedLabelStyle:
                          TextStyle(fontWeight: FontWeight.w500),
                      labelStyle: TextStyle(fontWeight: FontWeight.w700),
                      tabs: _buildTabs(),
                    ),
                  ),
                ),
                Consumer<CampaignManager>(
                    builder: (context, cm, child) => [
                          CampaignDescription(),
                          CampaignNews(),
                          CampaignSessions(),
                        ][cm.tabIndex]),
                SliverToBoxAdapter(
                  child: YMargin(100),
                )
              ]));
        });
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
  final int value;
  final String description;
  final bool isDark;

  _StatCollumn({
    this.value,
    this.description,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    BaseTheme _bTheme = ThemeManager.of(context).colors;
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: isDark ? _bTheme.dark : _bTheme.contrast,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Constants.radius)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AutoSizeText(
              "${Numeral(value ?? 0).value()}",
              textAlign: TextAlign.center,
              maxLines: 1,
              style: Theme.of(context).textTheme.headline5.copyWith(
                    color: isDark ? _bTheme.contrast : _bTheme.dark,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              description,
              style: TextStyle(
                  color: isDark ? _bTheme.contrast : _bTheme.dark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
