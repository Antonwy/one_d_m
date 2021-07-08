import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/Components/BottomDialog.dart';
import 'package:one_d_m/Components/CustomOpenContainer.dart';
import 'package:one_d_m/Components/DiscoveryHolder.dart';
import 'package:one_d_m/Components/DonationDialogWidget.dart';
import 'package:one_d_m/Components/DonationWidget.dart';
import 'package:one_d_m/Components/NewsPost.dart';
import 'package:one_d_m/Components/CampaignHeader.dart';
import 'package:one_d_m/Components/SessionList.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/DynamicLinkManager.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/Numeral.dart';
import 'package:one_d_m/Helper/Organisation.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:one_d_m/Pages/HomePage/ProfilePage.dart';
import 'package:one_d_m/Pages/OrganisationPage.dart';
import 'package:one_d_m/Pages/create_post.dart';
import 'package:one_d_m/utils/video/video_widget.dart';
import 'package:provider/provider.dart';
import 'package:social_share/social_share.dart';
import 'package:visibility_detector/visibility_detector.dart';

class NewCampaignPage extends StatefulWidget {
  Campaign campaign;
  ScrollController scrollController;

  NewCampaignPage(this.campaign, {Key key, this.scrollController})
      : super(key: key);

  @override
  _NewCampaignPageState createState() => _NewCampaignPageState();
}

class _NewCampaignPageState extends State<NewCampaignPage>
    with SingleTickerProviderStateMixin {
  TextTheme _textTheme;
  BaseTheme _bTheme;
  bool _subscribed = false;
  Campaign campaign;
  ScrollController _scrollController;
  TabController _tabController;
  int _tabIndex;

  Stream<Campaign> _campaignStream;
  Future<Organisation> _organizationFuture;
  bool _isLoading = false;
  bool isInView = false;
  bool _muted = true;

  @override
  void initState() {
    _scrollController = widget.scrollController ?? ScrollController();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _tabIndex = _tabController.index;
    _tabController.addListener(() {
      setState(() {
        _tabIndex = _tabController.index;
      });
    });

    _organizationFuture = widget.campaign?.authorId == null
        ? null
        : DatabaseService.getOrganisation(widget.campaign?.authorId);

    _campaignStream = DatabaseService.getCampaignStream(widget.campaign?.id);

    context.read<FirebaseAnalytics>().setCurrentScreen(
        screenName: widget.campaign?.name == null
            ? "Campaign Page"
            : "${widget.campaign.name} Page");

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

  Future<void> _shareCampaign() async {
    if ((campaign?.name?.isEmpty ?? true) ||
        (campaign?.imgUrl?.isEmpty ?? true)) return;
    SocialShare.shareOptions(
        (await DynamicLinkManager.of(context).createCampaignLink(campaign))
            .toString());
  }

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;
    _bTheme = ThemeManager.of(context).colors;
    return StreamBuilder<Campaign>(
        initialData: widget.campaign,
        stream: _campaignStream,
        builder: (context, snapshot) {
          campaign = snapshot.data;
          return Scaffold(
              backgroundColor: ColorTheme.appBg,
              floatingActionButton: OfflineBuilder(
                  child: Container(),
                  connectivityBuilder: (context, connection, child) {
                    bool activated = connection != ConnectivityResult.none;
                    return Consumer<UserManager>(builder: (context, um, child) {
                      return DiscoveryHolder.donateButton(
                        tapTarget: Icon(
                          Icons.arrow_forward,
                          color: _bTheme.contrast,
                        ),
                        child: FloatingActionButton.extended(
                            backgroundColor:
                                activated ? _bTheme.dark : Colors.grey,
                            label: Text("Unterstützen",
                                style: TextStyle(color: _bTheme.textOnDark)),
                            onPressed: activated &&
                                    snapshot.connectionState ==
                                        ConnectionState.active &&
                                    snapshot.hasData
                                ? () {
                                    print(snapshot);
                                    BottomDialog bd = BottomDialog(context);
                                    bd.show(DonationDialogWidget(
                                      campaign: snapshot.data,
                                      uid: um.uid,
                                      user: um.user,
                                      context: context,
                                      close: bd.close,
                                      controller: _scrollController,
                                    ));
                                  }
                                : () {
                                    Helper.showConnectionSnackBar(context);
                                  }),
                      );
                    });
                  }),
              body: CustomScrollView(controller: _scrollController, slivers: [
                SliverToBoxAdapter(
                  child: VisibilityDetector(
                    key: Key(widget.campaign.id),
                    onVisibilityChanged: (VisibilityInfo info) {
                      var visiblePercentage = (info.visibleFraction) * 100;
                      if (mounted) {
                        if (visiblePercentage == 100) {
                          setState(() {
                            isInView = true;
                          });
                        } else {
                          setState(() {
                            isInView = false;
                          });
                        }
                      }
                    },
                    child: Stack(
                      children: [
                        Stack(
                          children: [
                            campaign?.longVideoUrl != null
                                ? VideoWidget(
                                    height: MediaQuery.of(context).size.width,
                                    url: campaign?.longVideoUrl,
                                    play: isInView,
                                    imageUrl: campaign?.imgUrl,
                                    muted: _muted,
                                    toggleMuted: _toggleMuted,
                                    blurHash: campaign?.blurHash,
                                  )
                                : CachedNetworkImage(
                                    width: double.infinity,
                                    height: MediaQuery.of(context).size.width,
                                    imageUrl: campaign?.imgUrl ?? "",
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) => Container(
                                      height: 260,
                                      child: Center(
                                          child: Icon(
                                        Icons.error,
                                        color: ColorTheme.orange,
                                      )),
                                    ),
                                    placeholder: (context, url) =>
                                        campaign?.blurHash != null
                                            ? BlurHash(hash: campaign.blurHash)
                                            : Container(
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              ),
                                  ),
                            Positioned(
                              top: MediaQuery.of(context).padding.top,
                              right: 12,
                              left: 12,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  AppBarButton(
                                      elevation: 10,
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      icon: Icons.arrow_back),
                                  Row(
                                    children: [
                                      DiscoveryHolder.shareButton(
                                        tapTarget: Icon(
                                          CupertinoIcons.share,
                                          color: _bTheme.contrast,
                                        ),
                                        child: Center(
                                          child: AppBarButton(
                                              icon: CupertinoIcons.share,
                                              elevation: 10,
                                              onPressed: _shareCampaign),
                                        ),
                                      ),
                                      XMargin(6),
                                      FutureBuilder<Organisation>(
                                          future: _organizationFuture == null &&
                                                  campaign?.authorId != null
                                              ? DatabaseService.getOrganisation(
                                                  campaign?.authorId)
                                              : _organizationFuture,
                                          builder: (context, snapshot) {
                                            return AppBarButton(
                                              elevation: 10,
                                              onPressed: !snapshot.hasData
                                                  ? null
                                                  : () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  OrganisationPage(
                                                                      snapshot
                                                                          .data)));
                                                    },
                                              child: RoundedAvatar(
                                                snapshot.data?.thumbnailUrl ??
                                                    snapshot.data?.imgUrl,
                                                height: 15,
                                                color: ColorTheme.appBg,
                                                backgroundLight: true,
                                                loading: !snapshot.hasData,
                                                fit: BoxFit.contain,
                                                borderRadius: 6,
                                              ),
                                            );
                                          })
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                campaign?.longVideoUrl != null
                                    ? MuteButton(
                                        muted: _muted,
                                        toggle: _toggleMuted,
                                      )
                                    : SizedBox.shrink(),
                                SizedBox.shrink(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(12.0),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                                width: 220,
                                child: AutoSizeText(
                                  campaign?.name ?? "Laden...",
                                  maxLines: 1,
                                  style: _textTheme.headline5
                                      .copyWith(fontWeight: FontWeight.w700),
                                )),
                            FutureBuilder<Organisation>(
                                future: _organizationFuture == null &&
                                        campaign?.authorId != null
                                    ? DatabaseService.getOrganisation(
                                        campaign?.authorId)
                                    : _organizationFuture,
                                builder: (context, snapshot) {
                                  Organisation organisation = snapshot.data;
                                  return InkWell(
                                    onTap: !snapshot.hasData
                                        ? null
                                        : () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        OrganisationPage(
                                                            organisation)));
                                          },
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(text: 'by '),
                                          TextSpan(
                                              text:
                                                  '${organisation?.name ?? 'Laden...'}',
                                              style: _textTheme.bodyText1
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      decoration: TextDecoration
                                                          .underline,
                                                      color: _bTheme.dark)),
                                        ],
                                        style: _textTheme.bodyText1.copyWith(
                                            fontWeight: FontWeight.w400,
                                            color:
                                                _bTheme.dark.withOpacity(.54)),
                                      ),
                                    ),
                                  );
                                }),
                          ],
                        ),
                        Consumer<UserManager>(builder: (context, um, child) {
                          return um.uid == campaign?.adminId &&
                                  campaign?.adminId != null &&
                                  campaign.adminId.isNotEmpty
                              ? _createPostButton()
                              : StreamBuilder<bool>(
                                  initialData: false,
                                  stream: campaign?.id == null
                                      ? null
                                      : DatabaseService
                                          .hasSubscribedCampaignStream(
                                              um.uid, campaign?.id),
                                  builder: (context, snapshot) {
                                    _subscribed = snapshot.data;
                                    return _buildFollowButton(
                                        context,
                                        () async => _toggleSubscribed(um.uid),
                                        _subscribed);
                                  });
                        }),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      height: 90,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          _StatCollumn(
                              value: ((campaign?.amount ?? 0.0) /
                                      (campaign?.dvController ?? 1.0))
                                  .round(),
                              description:
                                  "${campaign?.unit ?? "Donation Votes"}"),
                          XMargin(6),
                          _StatCollumn(
                              value: campaign?.subscribedCount ?? 0,
                              description: "Abonnenten",
                              isDark: true),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _buildTags()),
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
                [
                  _buildExpandableContent(context, campaign?.description ?? ""),
                  _buildCampaignNews(),
                  _buildCampaignSessions(),
                ][_tabIndex],
                SliverToBoxAdapter(
                  child: YMargin(100),
                )
              ]));
        });
  }

  Widget _buildTags() {
    print("TAGS: ${campaign.tags}");
    return campaign.tags.isNotEmpty &&
            campaign.tags.where((el) => el.isNotEmpty).isNotEmpty
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (String tag in campaign?.tags)
                  if (tag.isNotEmpty) CampaignTag(text: tag)
              ],
            ),
          )
        : SizedBox.shrink();
  }

  void _toggleMuted() {
    setState(() {
      _muted = !_muted;
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

  Widget _buildCampaignNews() => StreamBuilder<List<News>>(
      stream: campaign?.id == null
          ? null
          : DatabaseService.getNewsFromCampaignStream(campaign?.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData || (snapshot.hasData && snapshot.data.isEmpty))
          return SliverToBoxAdapter(
            child: _buildEmptyWidget("Neuigkeiten"),
          );
        List<News> n = snapshot.data;
        n.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return SliverPadding(
          padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                (context, i) => NewsPost(
                      n[i],
                      withHeader: false,
                    ),
                childCount: n.length),
          ),
        );
      });

  Widget _buildEmptyWidget(String name) => Column(
        children: [
          SvgPicture.asset(
            'assets/images/no-news.svg',
            width: 200,
          ),
          YMargin(12),
          Text("Für dieses Projekt existieren noch keine $name.")
        ],
      );

  Widget _buildCampaignSessions() => SliverToBoxAdapter(
        child: StreamBuilder(
            stream: campaign?.id == null
                ? null
                : DatabaseService.getCertifiedSessionsFromCampaign(
                    campaign?.id),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<CertifiedSession> sessions = snapshot.data;

                if (sessions.isEmpty) return _buildEmptyWidget("Sessions");

                sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: Text(
                          '${sessions.length} Influencer engagieren sich für dieses Projekt.',
                          style: _textTheme.bodyText1),
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
                                    right: index == sessions.length - 1
                                        ? 12.0
                                        : 0.0),
                                child: SessionView(sessions[index]),
                              ),
                          itemCount: sessions.length),
                    ),
                  ],
                );
              } else {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(_bTheme.dark),
                        )),
                  ),
                );
              }
            }),
      );

  Widget _buildExpandableContent(BuildContext context, String text) =>
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${campaign?.shortDescription ?? ''}",
                style: _textTheme.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _bTheme.dark,
                    fontSize: 14),
              ),
              YMargin(6),
              Text(
                text,
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                    fontSize: 15,
                    color: _bTheme.dark,
                    fontWeight: FontWeight.w400),
              ),
              YMargin(6),
              campaign?.effects != null &&
                      campaign.effects.isNotEmpty &&
                      campaign.effects.where((el) => el.isNotEmpty).length > 0
                  ? Text(
                      "Was dieses Projekt bewirkt:",
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                          fontSize: 15,
                          color: _bTheme.dark,
                          fontWeight: FontWeight.w700),
                    )
                  : SizedBox.shrink(),
              YMargin(6),
              for (String effect in campaign?.effects)
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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                      fontSize: 15,
                                      color: _bTheme.dark,
                                      fontWeight: FontWeight.w400),
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

  Widget _buildFollowButton(
          BuildContext context, Function function, bool isFollow) =>
      RaisedButton(
          color: isFollow ? _bTheme.contrast : _bTheme.dark,
          textColor: isFollow ? _bTheme.textOnContrast : _bTheme.textOnDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          child: _isLoading
              ? SizedBox(
                  height: 18,
                  width: 18,
                  child: Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 3.0,
                        valueColor: new AlwaysStoppedAnimation<Color>(isFollow
                            ? _bTheme.textOnContrast
                            : _bTheme.textOnDark)),
                  ),
                )
              : AutoSizeText(
                  isFollow ? 'Entfolgen' : "Folgen",
                  maxLines: 1,
                ),
          onPressed: function);

  Widget _createPostButton() => CustomOpenContainer(
        closedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        closedElevation: 0,
        openBuilder: (context, close, scrollController) => CreatePostScreen(
          isSession: false,
          campaign: campaign,
          controller: scrollController,
        ),
        closedColor: Colors.transparent,
        closedBuilder: (context, open) => RaisedButton(
            color: _bTheme.dark,
            textColor: _bTheme.textOnDark,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            child: AutoSizeText("Post erstellen", maxLines: 1),
            onPressed: open),
      );

  Future<void> _toggleSubscribed(String uid) async {
    setState(() {
      _isLoading = true;
    });
    if (_subscribed) {
      await DatabaseService.deleteSubscription(campaign, uid)
          .then((value) => setState(() {
                _isLoading = false;
              }));
      await context.read<FirebaseAnalytics>().logEvent(
          name: "Left Campaign", parameters: {"campaign": campaign.name});
    } else {
      await DatabaseService.createSubscription(campaign, uid)
          .then((value) => setState(() {
                _isLoading = false;
              }));
      await context.read<FirebaseAnalytics>().logEvent(
          name: "Joined Campaign", parameters: {"campaign": campaign.name});
    }
  }
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
