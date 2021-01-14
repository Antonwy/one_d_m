import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:one_d_m/Components/BottomDialog.dart';
import 'package:one_d_m/Components/DonationDialogWidget.dart';
import 'package:one_d_m/Components/NewsPost.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/CertifiedSessionsList.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Donation.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/Numeral.dart';
import 'package:one_d_m/Helper/Organisation.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:one_d_m/Pages/CreateNewsPage.dart';
import 'package:one_d_m/Pages/FullscreenImages.dart';
import 'package:one_d_m/Pages/OrganisationPage.dart';
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
  MediaQueryData _mq;
  ScrollController _scrollController;
  ValueNotifier _scrollOffset;

  Stream<Campaign> _campaignStream;
  Stream<List<Donation>> _donationStream;

  bool _isAuthorOfCampaign = false;
  bool _isLoading = false;

  @override
  void initState() {
    _scrollController = widget.scrollController ?? ScrollController();

    _scrollOffset = ValueNotifier(0);

    _scrollController.addListener(() {
      _scrollOffset.value = _scrollController.offset;
    });

    _campaignStream = DatabaseService.getCampaignStream(widget.campaign.id);
    _donationStream =
        DatabaseService.getDonationFromCampaignStream(widget.campaign.id);

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollOffset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;
    _mq = MediaQuery.of(context);
    _bTheme = ThemeManager.of(context).colors;
    return Scaffold(
        floatingActionButton: OfflineBuilder(
            child: Container(),
            connectivityBuilder: (context, connection, child) {
              bool activated = connection != ConnectivityResult.none;
              return Consumer<UserManager>(builder: (context, um, child) {
                return StreamBuilder<Campaign>(
                    initialData: widget.campaign,
                    stream: _campaignStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data.authorId != null) {
                        _isAuthorOfCampaign = snapshot.data.authorId == um.uid;
                      }

                      return FloatingActionButton.extended(
                          backgroundColor:
                              activated ? _bTheme.dark : Colors.grey,
                          label: _isAuthorOfCampaign
                              ? Text("Post erstellen")
                              : Text("Unterstützen"),
                          onPressed: activated
                              ? _isAuthorOfCampaign
                                  ? () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (c) =>
                                                  CreateNewsPage(campaign)));
                                    }
                                  : () {
                                      BottomDialog bd = BottomDialog(context);
                                      bd.show(DonationDialogWidget(
                                        campaign: snapshot.data,
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

              return Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: _mq.size.height * .3 + 30,
                      width: _mq.size.width,
                      child: CachedNetworkImage(
                        imageUrl: widget.campaign.imgUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ValueListenableBuilder(
                        valueListenable: _scrollOffset,
                        builder: (context, value, child) {
                          return Container(
                              height: (_mq.size.height * .7 + value)
                                  .clamp(0, _mq.size.height),
                              width: double.infinity,
                              child: Material(
                                color: ColorTheme.white,
                                elevation: 20,
                                clipBehavior: Clip.antiAlias,
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(30)),
                              ));
                        }),
                  ),
                  MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          SliverToBoxAdapter(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FullscreenImages([
                                              campaign.imgUrl,
                                              ...campaign.moreImages
                                            ])));
                              },
                              child: SizedBox(
                                height: _mq.size.height * .3,
                                child: Container(
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: 220,
                                                    child: AutoSizeText(
                                                      campaign.name,
                                                      maxLines: 1,
                                                      style: _textTheme
                                                          .headline5
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700),
                                                    ),
                                                  ),
                                                  FutureBuilder<Organisation>(
                                                      future: DatabaseService
                                                          .getOrganisation(
                                                              campaign
                                                                  .authorId),
                                                      builder:
                                                          (context, snapshot) {
                                                        Organisation
                                                            organisation =
                                                            snapshot.data;
                                                        return InkWell(
                                                          onTap:
                                                              !snapshot.hasData
                                                                  ? null
                                                                  : () {
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => OrganisationPage(organisation)));
                                                                    },
                                                          child: Text(
                                                            'by ${organisation?.name ?? 'Laden...'}',
                                                            style: _textTheme
                                                                .bodyText1
                                                                .copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                          ),
                                                        );
                                                      }),
                                                ],
                                              ),
                                              Expanded(child: SizedBox()),
                                              Consumer<UserManager>(builder:
                                                  (context, um, child) {
                                                return StreamBuilder<bool>(
                                                    initialData: false,
                                                    stream: DatabaseService
                                                        .hasSubscribedCampaignStream(
                                                            um.uid,
                                                            campaign.id),
                                                    builder:
                                                        (context, snapshot) {
                                                      _subscribed =
                                                          snapshot.data;
                                                      return _buildFollowButton(
                                                          context,
                                                          () async =>
                                                              _toggleSubscribed(
                                                                  um.uid),
                                                          _subscribed);
                                                    });
                                              }),
                                            ],
                                          ),
                                          const YMargin(12),
                                          Text(
                                            "${campaign?.shortDescription}",
                                            style: _textTheme.caption.copyWith(
                                                fontWeight: FontWeight.w400,
                                                color: Helper.hexToColor(
                                                    '#2e313f'),
                                                fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const YMargin(12),
                                  ],
                                ),
                                const YMargin(12),
                                Container(
                                  height: 100,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      _StatCollumn(
                                          value: campaign.amount,
                                          description: "Donation Votes"),
                                      _StatCollumn(
                                          value: campaign.subscribedCount,
                                          description: "Abonnenten",
                                          isDark: true),
                                    ],
                                  ),
                                ),
                                const YMargin(12),
                                Text("Beschreibung",
                                    style: _textTheme.headline6.copyWith(
                                      fontWeight: FontWeight.w600,
                                    )),
                                const YMargin(8),
                                _buildExpandableContent(
                                    context, campaign.description ?? ""),
                              ]),
                            ),
                          ),
                          _buildCampaignSessions(),
                          StreamBuilder<List<News>>(
                              stream: DatabaseService.getNewsFromCampaignStream(
                                  campaign),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    (snapshot.hasData && snapshot.data.isEmpty))
                                  return SliverToBoxAdapter(
                                    child: SizedBox(
                                      height: 100,
                                    ),
                                  );
                                List<News> n = snapshot.data;
                                n.sort((a,b) =>b.createdAt.compareTo(a.createdAt));

                                return SliverPadding(
                                  padding: EdgeInsets.fromLTRB(18, 0, 18, 80),
                                  sliver: SliverList(
                                      delegate: SliverChildListDelegate([
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 18.0),
                                      child: Text("Neuigkeiten",
                                          style: _textTheme.headline6),
                                    ),
                                    ListView.builder(
                                      itemCount: n.length,
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemBuilder: (_,index)=>NewsPost(n[index],withCampaign: false,),
                                    )
                                  ])),
                                );
                              }),
                        ]),
                  ),
                  Positioned(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Material(
                        clipBehavior: Clip.antiAlias,
                        shape: CircleBorder(),
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: IconButton(
                              icon: Icon(Icons.arrow_downward),
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                        ),
                      ),
                    ),
                    top: MediaQuery.of(context).padding.top,
                    left: 0,
                  ),
                  Consumer<UserManager>(
                    builder: (context, um, child) => StreamBuilder<Campaign>(
                        initialData: widget.campaign,
                        stream: _campaignStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData &&
                              snapshot.data.authorId != null &&
                              snapshot.data.authorId != um.uid)
                            return Container();

                          if (!snapshot.hasData ||
                              snapshot.data?.authorId == null ||
                              snapshot.data?.authorId != null)
                            return Container();

                          return Positioned(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Material(
                                clipBehavior: Clip.antiAlias,
                                shape: CircleBorder(),
                                elevation: 10,
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        DatabaseService.deleteCampaign(
                                            campaign);
                                      }),
                                ),
                              ),
                            ),
                            top: MediaQuery.of(context).padding.top,
                            right: 0,
                          );
                        }),
                  ),
                ],
              );
            }));
  }

  Widget _buildCampaignSessions() => SliverToBoxAdapter(
        child: StreamBuilder(
            stream: DatabaseService.getCertifiedSessionsFromCampaign(
                widget.campaign.id),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Session> sessions = snapshot.data;

                if (sessions.isEmpty) return SizedBox.shrink();

                sessions.sort((a,b) =>b.createdAt.compareTo(a.createdAt));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 14.0),
                      child: Text("Sessions",
                          style: _textTheme.headline6.copyWith(
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: Text(
                          '${sessions.length} Influencer engagieren sich für dieses Projekt',
                          style: _textTheme.headline6.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Colors.black.withOpacity(0.6))),
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
                  child: SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator()),
                );
              }
            }),
      );

  Widget _buildExpandableContent(BuildContext context, String text) =>
      ExpandableNotifier(
        child: Column(
          children: [
            Expandable(
              collapsed: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    maxLines: 4,
                    softWrap: true,
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                        fontSize: 15,
                        color: Helper.hexToColor('#2e313f'),
                        fontWeight: FontWeight.w400),
                  ),
                  text.length > 90
                      ? Align(
                          alignment: Alignment.bottomLeft,
                          child: ExpandableButton(
                              child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.zero,
                                child: Icon(
                                  Icons.keyboard_arrow_down_outlined,
                                  color: Colors.black,
                                  size: 32,
                                ),
                              ),
                              Text(
                                'mehr',
                                textAlign: TextAlign.start,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700),
                              ),
                            ],
                          )),
                        )
                      : SizedBox.shrink()
                ],
              ),
              expanded: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    maxLines: null,
                    softWrap: true,
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                        fontSize: 15,
                        color: Helper.hexToColor('#2e313f'),
                        fontWeight: FontWeight.w400),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: ExpandableButton(
                        child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.keyboard_arrow_up_outlined,
                          color: Colors.black,
                        ),
                        Text(
                          'weniger',
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    )),
                  )
                ],
              ),
            )
          ],
        ),
      );

  Widget _buildFollowButton(
          BuildContext context, Function function, bool isFollow) =>
      Container(
        width: 90,
        height: 50,
        child: MaterialButton(
            color: _bTheme.dark,
            textColor: _bTheme.light,
            child: _isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              new AlwaysStoppedAnimation<Color>(Colors.white)),
                    ),
                  )
                : AutoSizeText(
                    isFollow ? 'Entfolgen' : "Folgen",
                    maxLines: 1,
                    style: Theme.of(context).textTheme.button.copyWith(
                          color: ThemeManager.of(context).colors.light,
                        ),
                  ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onPressed: function),
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
        elevation: 0,
        color: isDark ? _bTheme.dark : _bTheme.contrast,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "${Numeral(value ?? 0).value()}",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyText1.copyWith(
                  color: isDark ? _bTheme.contrast : _bTheme.dark,
                  fontWeight: FontWeight.w500,
                  fontSize: 28),
            ),
            Text(
              description,
              style: TextStyle(
                  color: isDark ? _bTheme.contrast : _bTheme.dark,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

