import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/Components/CampaignHeader.dart';
import 'package:one_d_m/Components/CustomOpenContainer.dart';
import 'package:one_d_m/Components/DonationWidget.dart';
import 'package:one_d_m/Components/FollowButton.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/CampaignsManager.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Donation.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/Numeral.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/EditProfile.dart';
import 'package:one_d_m/Pages/FollowersListPage.dart';
import 'package:one_d_m/Pages/UsersDonationsPage.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

class UserPage extends StatefulWidget {
  User user;
  ScrollController scrollController;

  UserPage(this.user, {this.scrollController});

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

  List<Campaign> campaigns;

  double _staticHeight;
  static final double _staticHeaderTop = 76;

  Stream _donationStream;

  double _headerHeight, _headerTop = _staticHeaderTop, _scrollOffset = 0.0;

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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    um = Provider.of<UserManager>(context);
    _isOwnPage = widget.user.id == um.uid;
    mq = MediaQuery.of(context);
    _staticHeight = mq.size.height * .55;
    _headerHeight = _staticHeight + mq.padding.top;
    _headerTop = _staticHeaderTop + mq.padding.top;

    return Scaffold(
      body: Consumer<UserManager>(
        builder: (context, um, child) => StreamBuilder<User>(
            initialData: user,
            stream: DatabaseService.getUserStream(widget.user.id),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null)
                user = snapshot.data;
              return CustomScrollView(
                controller: widget.scrollController,
                slivers: <Widget>[
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: UserHeader(user),
                  ),
                  StreamBuilder<List<Donation>>(
                      stream: _donationStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return SliverToBoxAdapter();
                        if (snapshot.data.isEmpty) return SliverToBoxAdapter();
                        return SliverPadding(
                          padding: const EdgeInsets.fromLTRB(10, 18, 10, 0),
                          sliver: SliverToBoxAdapter(
                            child: Text(
                              "Letzte Spenden",
                              style: _theme.textTheme.headline6,
                            ),
                          ),
                        );
                      }),
                  StreamBuilder<List<Donation>>(
                      stream: _donationStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return SliverToBoxAdapter();
                        if (snapshot.data.isEmpty) return SliverToBoxAdapter();
                        return SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          sliver: SliverList(
                              delegate: SliverChildListDelegate(
                                  _generateDonations(snapshot.data))),
                        );
                      }),
                  Consumer<CampaignsManager>(builder: (context, cm, child) {
                    campaigns = cm.getSubscribedCampaigns(user);

                    if (campaigns.isEmpty)
                      return SliverToBoxAdapter(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(
                              height: 25,
                            ),
                            SvgPicture.asset(
                              "assets/images/no-news.svg",
                              height: 200,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                                "${um.uid == user.id ? "Du" : "${user.name ?? "Gelöschter Account"}"} ${um.uid == user.id ? "hast" : "hat"} noch keine Projekte abonniert!"),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      );

                    return SliverList(
                      delegate: SliverChildListDelegate(_generateChildren()),
                    );
                  }),
                ],
              );
            }),
      ),
    );

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
                        child: CustomScrollView(
                            controller: _scrollController,
                            slivers: [
                              SliverToBoxAdapter(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                            padding: const EdgeInsets.all(18.0),
                                            child: Text(
                                              "Letzte Spenden",
                                              style: _theme.textTheme.headline6,
                                            ),
                                          );
                                        })
                                  ],
                                ),
                              ),
                              StreamBuilder<List<Donation>>(
                                  stream: _donationStream,
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData)
                                      return SliverToBoxAdapter();
                                    return SliverPadding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      sliver: SliverList(
                                          delegate: SliverChildListDelegate(
                                              _generateDonations(
                                                  snapshot.data))),
                                    );
                                  }),
                              Consumer<CampaignsManager>(
                                  builder: (context, cm, child) {
                                campaigns = cm.getSubscribedCampaigns(user);

                                if (campaigns.isEmpty)
                                  return SliverToBoxAdapter(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        SizedBox(
                                          height: 25,
                                        ),
                                        SvgPicture.asset(
                                          "assets/images/no-news.svg",
                                          height: 200,
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                            "${um.uid == user.id ? "Du" : "${user.name ?? "Gelöschter Account"}"} ${um.uid == user.id ? "hast" : "hat"} noch keine Projekte abonniert!"),
                                        SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    ),
                                  );

                                return SliverList(
                                  delegate: SliverChildListDelegate(
                                      _generateChildren()),
                                );
                              }),
                            ]),
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
                                                    imageErrorBuilder:
                                                        (context, _, __) =>
                                                            Container(
                                                      color: ColorTheme.blue,
                                                    ),
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
                                                  // Expanded(child: Container()),
                                                  Expanded(
                                                    child: Container(
                                                      width: double.infinity,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal:
                                                                    18.0),
                                                        child: FittedBox(
                                                          fit: BoxFit.contain,
                                                          child: AutoSizeText(
                                                            "${user?.name}",
                                                            textAlign: TextAlign
                                                                .center,
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ),
                                                      ),
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
                                                                number: "${Numeral(user.donatedAmount ?? 0).value()} DC"
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
                                                      child: OfflineBuilder(
                                                          child: Container(),
                                                          connectivityBuilder:
                                                              (context,
                                                                  connection,
                                                                  child) {
                                                            return _isOwnPage
                                                                ? Center(
                                                                    child:
                                                                        FloatingActionButton(
                                                                    heroTag: "",
                                                                    elevation:
                                                                        0,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .white,
                                                                    onPressed:
                                                                        () {
                                                                      if (connection ==
                                                                          ConnectivityResult
                                                                              .none) {
                                                                        Helper.showConnectionSnackBar(
                                                                            context);
                                                                        return;
                                                                      }
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (c) => EditProfile()));
                                                                    },
                                                                    child: Icon(
                                                                      Icons
                                                                          .edit,
                                                                      color: Colors
                                                                          .black87,
                                                                    ),
                                                                  ))
                                                                : _followButton();
                                                          })),
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
                                child: AutoSizeText(
                                  "${user.name ?? "Gelöschter Account"}",
                                  maxLines: 1,
                                )),
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

  Future<void> _toggleFollow() async {
    if (_followed) {
      await DatabaseService.deleteFollow(um.uid, user.id);
    } else {
      await DatabaseService.createFollow(um.uid, user.id);
    }
  }

  Widget _followButton() {
    return user.name == null
        ? Container()
        : StreamBuilder<bool>(
            initialData: false,
            stream: DatabaseService.getFollowStream(um.uid, user.id),
            builder: (context, snapshot) {
              _followed = snapshot.data;

              return Center(
                  child: FollowButton(
                followed: _followed,
                onPressed: _toggleFollow,
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
      padding: const EdgeInsets.only(left: 10.0, bottom: 10, top: 20),
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

class UserHeader extends SliverPersistentHeaderDelegate {
  final int index = 0;
  final User user;
  ThemeData _theme;
  double _minExtend = 80.0;

  UserHeader(this.user);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    _theme = Theme.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      _minExtend = MediaQuery.of(context).padding.top + 56.0;
      final double percentage =
          (constraints.maxHeight - minExtent) / (maxExtent - minExtent);

      return Container(
        height: constraints.maxHeight,
        child: Material(
          color: ColorTheme.whiteBlue,
          elevation: 1,
          child: SafeArea(
            bottom: false,
            child: Wrap(
              alignment: WrapAlignment.center,
              runSpacing: 20,
              spacing: 20,
              children: <Widget>[
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: IconThemeData(color: ColorTheme.blue),
                  title: Text(
                    "${user?.name ?? "Gelöschter Account"}",
                    style: TextStyle(color: ColorTheme.blue),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        width: 75,
                        height: 75,
                        child: RoundedAvatar(user.imgUrl)),
                    SizedBox(
                      width: 20,
                    ),
                    _followButton()
                  ],
                ),
                Container(
                  width: constraints.maxWidth * .9,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      _followersCollumn(
                          text: "Abonnenten",
                          stream:
                              DatabaseService.getFollowedUsersStream(user.id)),
                      Material(
                        borderRadius: BorderRadius.circular(5),
                        clipBehavior: Clip.antiAlias,
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: (user?.donatedAmount == null
                                      ? 0
                                      : user.donatedAmount) >
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
                              text: "Gespendet",
                              number:
                                  "${Numeral(user?.donatedAmount).value()} DC"),
                        ),
                      ),
                      _followersCollumn(
                          text: "Abonniert",
                          stream:
                              DatabaseService.getFollowingUsersStream(user.id)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate _) => true;

  @override
  double get maxExtent => 280.0;

  @override
  double get minExtent => _minExtend;

  Widget _followButton() {
    return user.name == null
        ? Container()
        : Consumer<UserManager>(builder: (context, um, child) {
            if (um.uid == user.id)
              return OfflineBuilder(
                  child: Container(),
                  connectivityBuilder: (context, connection, child) {
                    if (connection == ConnectivityResult.none)
                      return FloatingActionButton(
                        onPressed: () {
                          Helper.showConnectionSnackBar(context);
                        },
                        child: Icon(
                          Icons.signal_wifi_off,
                          color: ColorTheme.orange,
                        ),
                        backgroundColor: ColorTheme.whiteBlue,
                      );
                    return CustomOpenContainer(
                      openBuilder: (context, close, controller) =>
                          EditProfile(),
                      closedShape: CircleBorder(),
                      closedBuilder: (context, open) => Container(
                        width: 56,
                        height: 56,
                        child: InkWell(
                          onTap: open,
                          child: Icon(
                            Icons.edit,
                            color: ColorTheme.blue,
                          ),
                        ),
                      ),
                    );
                  });

            return StreamBuilder<bool>(
                initialData: false,
                stream: DatabaseService.getFollowStream(um.uid, user.id),
                builder: (context, snapshot) {
                  bool _followed = snapshot.data;

                  return Center(
                      child: FollowButton(
                    followed: _followed,
                    onPressed: () async {
                      await _toggleFollow(um.uid, _followed);
                    },
                  ));
                });
          });
  }

  Future<void> _toggleFollow(String uid, bool followed) async {
    if (followed) {
      await DatabaseService.deleteFollow(uid, user.id);
    } else {
      await DatabaseService.createFollow(uid, user.id);
    }
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
    return Container(
      width: 100,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            AutoSizeText(
              number.toString(),
              maxLines: 1,
              style: _theme.accentTextTheme.headline6
                  .copyWith(color: ColorTheme.blue),
            ),
            Text(
              text,
              style: _theme.accentTextTheme.bodyText1
                  .copyWith(color: ColorTheme.blue.withOpacity(.5)),
            )
          ],
        ),
      ),
    );
  }
}
