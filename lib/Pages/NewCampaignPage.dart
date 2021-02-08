import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/Components/BottomDialog.dart';
import 'package:one_d_m/Components/CustomOpenContainer.dart';
import 'package:one_d_m/Components/DonationDialogWidget.dart';
import 'package:one_d_m/Components/DonationWidget.dart';
import 'package:one_d_m/Components/NewsPost.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/CertifiedSessionsList.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/Numeral.dart';
import 'package:one_d_m/Helper/Organisation.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:one_d_m/Pages/FullscreenImages.dart';
import 'package:one_d_m/Pages/OrganisationPage.dart';
import 'package:one_d_m/Pages/create_post.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    _scrollController = widget.scrollController ?? ScrollController();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _tabIndex = _tabController.index;
    _tabController.addListener(() {
      setState(() {
        _tabIndex = _tabController.index;
      });
    });

    _organizationFuture = widget.campaign?.authorId == null
        ? null
        : DatabaseService.getOrganisation(widget.campaign?.authorId);

    _campaignStream = widget.campaign?.id == null
        ? null
        : DatabaseService.getCampaignStream(widget.campaign?.id);

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;
    _bTheme = ThemeManager.of(context).colors;
    return Scaffold(
        backgroundColor: ColorTheme.appBg,
        floatingActionButton: OfflineBuilder(
            child: Container(),
            connectivityBuilder: (context, connection, child) {
              bool activated = connection != ConnectivityResult.none;
              return Consumer<UserManager>(builder: (context, um, child) {
                return StreamBuilder<Campaign>(
                    initialData: widget.campaign,
                    stream: _campaignStream,
                    builder: (context, snapshot) {
                      return FloatingActionButton.extended(
                          backgroundColor:
                              activated ? _bTheme.dark : Colors.grey,
                          label: Text("Unterstützen"),
                          onPressed: activated
                              ? () {
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
                                });
                    });
              });
            }),
        body: StreamBuilder<Campaign>(
            initialData: widget.campaign,
            stream: _campaignStream,
            builder: (context, snapshot) {
              campaign = snapshot.data;

              return CustomScrollView(controller: _scrollController, slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: _bTheme.dark,
                        size: 30,
                      ),
                      onPressed: () => Navigator.pop(context)),
                  actions: [
                    FutureBuilder<Organisation>(
                        future: _organizationFuture == null &&
                                campaign?.authorId != null
                            ? DatabaseService.getOrganisation(
                                campaign?.authorId)
                            : _organizationFuture,
                        builder: (context, snapshot) {
                          return Container(
                            height: 30,
                            width: 30,
                            margin: const EdgeInsets.all(12),
                            child: GestureDetector(
                              onTap: !snapshot.hasData
                                  ? null
                                  : () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  OrganisationPage(
                                                      snapshot.data)));
                                      ;
                                    },
                              child: RoundedAvatar(
                                snapshot.data?.thumbnailUrl ??
                                    snapshot.data?.imgUrl,
                                elevation: 1,
                                color: ColorTheme.appBg,
                                backgroundLight: true,
                                loading: !snapshot.hasData,
                                fit: BoxFit.contain,
                                borderRadius: 6,
                              ),
                            ),
                          );
                        })
                  ],
                ),
                SliverToBoxAdapter(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FullscreenImages(
                                  [campaign.imgUrl, ...campaign.moreImages])));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Container(
                        height: 250,
                        width: double.infinity,
                        child: Material(
                          clipBehavior: Clip.antiAlias,
                          elevation: 10,
                          borderRadius: BorderRadius.circular(6),
                          child: CachedNetworkImage(
                            imageUrl: widget.campaign.imgUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
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
                              ),
                            ),
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
                          return um.uid == widget.campaign.authorId
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
                              value: campaign?.amount ?? 0,
                              description: "Donation Votes"),
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
              ]);
            }));
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
            stream: widget.campaign?.id == null
                ? null
                : DatabaseService.getCertifiedSessionsFromCampaign(
                    widget.campaign?.id),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Session> sessions = snapshot.data;

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
                      height: 116,
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
                                child: CertifiedSessionView(sessions[index]),
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
              Text(
                "Was dieses Project bewirkt:",
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                    fontSize: 15,
                    color: _bTheme.dark,
                    fontWeight: FontWeight.w700),
              ),
              YMargin(6),
              for (String effect in campaign?.effects)
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
          campaign: widget.campaign,
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
    if (_subscribed)
      await DatabaseService.deleteSubscription(campaign, uid)
          .then((value) => setState(() {
                _isLoading = false;
              }));
    else
      await DatabaseService.createSubscription(campaign, uid)
          .then((value) => setState(() {
                _isLoading = false;
              }));
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
