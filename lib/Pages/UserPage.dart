import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:one_d_m/Components/CampaignHeader.dart';
import 'package:one_d_m/Components/DonationWidget.dart';
import 'package:one_d_m/Components/FollowButton.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/CampaignsManager.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Donation.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/EditProfile.dart';
import 'package:one_d_m/Pages/FollowersListPage.dart';
import 'package:one_d_m/Pages/UsersDonationsPage.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

class UserPage extends StatefulWidget {
  User user;

  UserPage(this.user);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> with TickerProviderStateMixin {
  bool _followed = false;
  bool _isOwnPage = false;

  ThemeData _theme;
  UserManager um;
  MediaQueryData mq;

  ScrollController _scrollController;
  AnimationController _controller;
  AnimationController _transitionController;
  AnimationController _followController;

  List<Campaign> campaigns;

  static final double _staticHeight = 430;
  static final double _staticHeaderTop = 76;

  Stream _donationStream;

  double _headerHeight = _staticHeight,
      _headerTop = _staticHeaderTop,
      _scrollOffset = 0.0;

  User user;

  @override
  void initState() {
    super.initState();

    user = widget.user;

    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    _transitionController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..forward();

    _followController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 150));

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset;
          _controller.value =
              Helper.mapValue(_scrollOffset, 0, _headerHeight - 76, 0, 1);
        });
      });

    _donationStream = DatabaseService.getDonationsFromUserLimit(widget.user.id);
  }

  @override
  void dispose() {
    _controller.dispose();
    _transitionController.dispose();
    _followController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    um = Provider.of<UserManager>(context);
    _isOwnPage = widget.user.id == um.uid;
    mq = MediaQuery.of(context);
    _headerHeight = _staticHeight + mq.padding.top;
    _headerTop = _staticHeaderTop + mq.padding.top;

    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Consumer<UserManager>(
          builder: (context, um, child) => StreamBuilder<User>(
              initialData: widget.user,
              stream: DatabaseService.getUserStream(widget.user.id),
              builder: (context, snapshot) {
                user = snapshot.data;
                return Stack(overflow: Overflow.clip, children: <Widget>[
                  Positioned.fill(
                    child: FadeTransition(
                      opacity: _transitionController,
                      child: Container(
                        color: Colors.white,
                        child: Consumer<CampaignsManager>(
                            builder: (context, cm, child) {
                          campaigns = cm.getSubscribedCampaigns(user);
                          if (campaigns.isEmpty) {
                            return Align(
                              alignment: Alignment.bottomCenter,
                              child: SafeArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Image.asset(
                                      "assets/images/clip-no-comments.png",
                                      height: mq.size.height - _headerHeight,
                                    ),
                                    Text(
                                        "${um.uid == user.id ? "Du" : "${user.name}"} ${um.uid == user.id ? "hast" : "hat"} noch keine Projekte abonniert!"),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return CustomScrollView(
                              controller: _scrollController,
                              slivers: [
                                SliverToBoxAdapter(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        height:
                                            _headerHeight - mq.padding.top + 25,
                                      ),
                                      StreamBuilder<List<Donation>>(
                                          stream: _donationStream,
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData)
                                              return Container();
                                            if (snapshot.data.isEmpty)
                                              return Container();
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(18.0),
                                              child: Text(
                                                "Letzte Spenden",
                                                style: _theme.textTheme.title,
                                              ),
                                            );
                                          })
                                    ],
                                  ),
                                ),
                                StreamBuilder<List<Donation>>(
                                    stream: DatabaseService
                                        .getDonationsFromUserLimit(user.id),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData)
                                        return SliverToBoxAdapter();
                                      return SliverPadding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 18),
                                        sliver: SliverGrid.count(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 10,
                                            mainAxisSpacing: 10,
                                            childAspectRatio: 1.5,
                                            children: _generateDonations(
                                                snapshot.data)),
                                      );
                                    }),
                                SliverList(
                                  delegate: SliverChildListDelegate(
                                      _generateChildren()),
                                ),
                              ]);
                        }),
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                      animation: _transitionController,
                      builder: (context, snapshot) {
                        return Positioned(
                          top: Tween(begin: -(_headerHeight), end: -20.0)
                              .animate(CurvedAnimation(
                                  parent: _transitionController,
                                  curve: ElasticOutCurve(1.4),
                                  reverseCurve: Curves.easeOut))
                              .value,
                          child: AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: ColorTheme.blue,
                                  boxShadow: [
                                    BoxShadow(
                                        color: ColorTheme.blue.withOpacity(.2),
                                        blurRadius: 10,
                                        offset: Offset(0, 10))
                                  ],
                                ),
                                child: ClipRect(
                                  child: SizedOverflowBox(
                                    size: Size(
                                        mq.size.width,
                                        (_headerHeight - _scrollOffset).clamp(
                                            _headerTop, _headerHeight + 400)),
                                    child: Container(
                                      height: _scrollOffset < 0
                                          ? (_headerHeight - _scrollOffset)
                                              .clamp(_headerTop,
                                                  _headerHeight + 400)
                                          : _headerHeight,
                                      width: mq.size.width,
                                      child: Opacity(
                                        opacity: 1 -
                                            CurvedAnimation(
                                                    parent: _controller,
                                                    curve: Interval(.5, 1.0))
                                                .value,
                                        child: Stack(
                                          children: <Widget>[
                                            user?.imgUrl == null
                                                ? SizedBox()
                                                : FadeInImage(
                                                    height: double.infinity,
                                                    width: double.infinity,
                                                    placeholder: MemoryImage(
                                                        kTransparentImage),
                                                    fadeInDuration: Duration(
                                                        milliseconds: 300),
                                                    image:
                                                        CachedNetworkImageProvider(
                                                            user.imgUrl),
                                                    fit: BoxFit.cover,
                                                  ),
                                            user?.imgUrl == null
                                                ? Container()
                                                : Container(
                                                    height: double.infinity,
                                                    width: double.infinity,
                                                    color: Colors.black
                                                        .withOpacity(.6),
                                                  ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: _headerTop),
                                              child: Column(
                                                children: <Widget>[
                                                  Expanded(child: Container()),
                                                  Center(
                                                    child: Text(
                                                      "${user?.name}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 50,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            18.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: <Widget>[
                                                        _followersCollumn(
                                                            text: "Abonnenten",
                                                            stream: DatabaseService
                                                                .getFollowedUsersStream(
                                                                    user.id),
                                                            alignment:
                                                                CrossAxisAlignment
                                                                    .start),
                                                        Material(
                                                          color: Colors
                                                              .transparent,
                                                          clipBehavior:
                                                              Clip.antiAlias,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          child: InkWell(
                                                            onTap: (user?.donatedAmount ==
                                                                            null
                                                                        ? 0
                                                                        : user
                                                                            .donatedAmount) >
                                                                    0
                                                                ? () {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (c) =>
                                                                                UsersDonationsPage(user)));
                                                                  }
                                                                : null,
                                                            child: _textNumberColumn(
                                                                text:
                                                                    "Gespendet",
                                                                number: "${user.donatedAmount ?? 0} DC"
                                                                    .toString()),
                                                          ),
                                                        ),
                                                        _followersCollumn(
                                                            text: "Abonniert",
                                                            stream: DatabaseService
                                                                .getFollowingUsersStream(
                                                                    user.id),
                                                            alignment:
                                                                CrossAxisAlignment
                                                                    .end),
                                                      ],
                                                    ),
                                                  ),
                                                  Opacity(
                                                      opacity:
                                                          1 - _controller.value,
                                                      child: _isOwnPage
                                                          ? Center(
                                                              child:
                                                                  FloatingActionButton(
                                                              heroTag: "",
                                                              elevation: 0,
                                                              backgroundColor:
                                                                  Colors.white,
                                                              onPressed: () {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (c) =>
                                                                                EditProfile()));
                                                              },
                                                              child: Icon(
                                                                Icons.edit,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                            ))
                                                          : _followButton()),
                                                  Expanded(child: Container())
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return AppBar(
                            brightness: Brightness.dark,
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            title: FadeTransition(
                                opacity: CurvedAnimation(
                                    parent: _controller,
                                    curve: Interval(.85, 1.0)),
                                child: Text("${user.name}")),
                            leading: IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white,
                                ),
                                onPressed: _pop),
                          );
                        }),
                  ),
                ]);
              }),
        ));
  }

  void _pop() {
    if (_transitionController.isAnimating) return;
    _transitionController.duration = Duration(milliseconds: 300);
    _transitionController.reverse().whenComplete(() {
      Navigator.pop(context);
    });
  }

  Widget _followersCollumn(
      {String text, Stream stream, CrossAxisAlignment alignment}) {
    return Container(
      height: 57,
      child: StreamBuilder<List<String>>(
          stream: stream,
          builder: (context, snapshot) {
            return Material(
              color: Colors.transparent,
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(5),
              child: InkWell(
                onTap: snapshot.hasData && snapshot.data.isNotEmpty
                    ? () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (c) => FollowersListPage(
                                      title: text,
                                      userIDs: snapshot.data,
                                    )));
                      }
                    : null,
                child: _textNumberColumn(
                    number: snapshot.hasData
                        ? snapshot.data.length.toString()
                        : "0",
                    text: text,
                    alignment: alignment),
              ),
            );
          }),
    );
  }

  Widget _textNumberColumn(
      {String text,
      String number,
      CrossAxisAlignment alignment = CrossAxisAlignment.center}) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            number.toString(),
            style: _theme.accentTextTheme.title,
          ),
          Text(
            text,
            style: _theme.accentTextTheme.body1.copyWith(
                color: _theme.accentTextTheme.body1.color.withOpacity(.95)),
          )
        ],
      ),
    );
  }

  void _toggleFollow() async {
    if (_followed) {
      await DatabaseService.deleteFollow(um.uid, user.id);
    } else {
      await DatabaseService.createFollow(um.uid, user.id);
    }
  }

  Widget _followButton() {
    return StreamBuilder<bool>(
        stream: DatabaseService.getFollowStream(um.uid, user.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _followed = snapshot.data;
            _followController.animateTo(_followed ? 1.0 : 0.0);
          }

          return Center(
              child: FollowButton(
            followed: _followed,
            onPressed: snapshot.hasData ? _toggleFollow : null,
          ));
        });
  }

  List<Widget> _generateDonations(List<Donation> donations) {
    return donations
        .map((d) => DonationWidget(
              d,
              withUsername: false,
            ))
        .toList();
  }

  List<Widget> _generateChildren() {
    List<Widget> list = [];

    list.add(Padding(
      padding: const EdgeInsets.only(left: 20.0, bottom: 10, top: 20),
      child: Text(
        "Unterstützte Projekte (${campaigns.length})",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      ),
    ));

    for (Campaign c in campaigns) {
      list.add(CampaignHeader(c));
    }

    list.add(SizedBox(height: mq.size.height * .5));

    return list;
  }
}
