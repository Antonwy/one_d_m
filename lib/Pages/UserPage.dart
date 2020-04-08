import 'dart:math';

import 'package:flutter/material.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Components/CampaignHeader.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/CampaignsManager.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/EditProfile.dart';
import 'package:one_d_m/Pages/FollowersListPage.dart';
import 'package:one_d_m/Pages/UsersDonationsPage.dart';
import 'package:provider/provider.dart';

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

  double _headerHeight = _staticHeight,
      _headerTop = _staticHeaderTop,
      _scrollOffset = 0.0;

  User user;

  @override
  void initState() {
    super.initState();

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
        body: StreamBuilder<User>(
            initialData: widget.user,
            stream: DatabaseService().getUserStream(widget.user.id),
            builder: (context, snapshot) {
              user = snapshot.data;
              return Stack(overflow: Overflow.clip, children: <Widget>[
                Positioned(
                  height: mq.size.height,
                  width: mq.size.width,
                  top: 0,
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
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Image.asset(
                                  "assets/images/clip-no-comments.png",
                                  height: mq.size.height - _headerHeight,
                                ),
                                Text("Du hast noch keine Projekte abonniert!"),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          );
                        }
                        return ListView(
                          controller: _scrollController,
                          children: _generateChildren(),
                        );
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
                                  color: Colors.indigo,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.indigo.withOpacity(.2),
                                        blurRadius: 10,
                                        offset: Offset(0, 10))
                                  ],
                                  borderRadius: BorderRadius.vertical(
                                      bottom: Radius.circular(
                                          Tween(begin: 30.0, end: 0.0)
                                              .animate(_controller)
                                              .value))),
                              child: ClipRect(
                                child: SizedOverflowBox(
                                  size: Size(
                                      mq.size.width,
                                      (_headerHeight - _scrollOffset).clamp(
                                          _headerTop, _headerHeight + 400)),
                                  child: Container(
                                    height: _headerHeight,
                                    width: mq.size.width,
                                    padding: EdgeInsets.only(top: _headerTop),
                                    child: Opacity(
                                      opacity: 1 -
                                          CurvedAnimation(
                                                  parent: _controller,
                                                  curve: Interval(.5, 1.0))
                                              .value,
                                      child: Column(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20.0),
                                            child: Container(
                                              height: 120,
                                              width: 120,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      width: 8,
                                                      color: Colors.white)),
                                              child: Avatar(
                                                user.imgUrl,
                                                elevation: 10,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Center(
                                            child: Text(
                                              "${user?.firstname} ${user?.lastname}",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(18.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                _followersCollumn(
                                                    text: "Abonnenten",
                                                    stream: DatabaseService()
                                                        .getFollowedUsersStream(
                                                            user),
                                                    alignment:
                                                        CrossAxisAlignment
                                                            .start),
                                                Material(
                                                  color: Colors.transparent,
                                                  clipBehavior: Clip.antiAlias,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  child: InkWell(
                                                    onTap:
                                                        user.donatedAmount > 0
                                                            ? () {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (c) =>
                                                                                UsersDonationsPage(user)));
                                                              }
                                                            : null,
                                                    child: _textNumberColumn(
                                                        text: "Gespendet",
                                                        number:
                                                            "${user.donatedAmount} DC"
                                                                .toString()),
                                                  ),
                                                ),
                                                _followersCollumn(
                                                    text: "Abonniert",
                                                    stream: DatabaseService()
                                                        .getFollowingUsersStream(
                                                            user),
                                                    alignment:
                                                        CrossAxisAlignment.end),
                                              ],
                                            ),
                                          ),
                                          Opacity(
                                              opacity: 1 - _controller.value,
                                              child: _isOwnPage
                                                  ? Center(
                                                      child:
                                                          FloatingActionButton(
                                                      elevation: 0,
                                                      backgroundColor:
                                                          Colors.white,
                                                      onPressed: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (c) =>
                                                                    EditProfile()));
                                                      },
                                                      child: Icon(
                                                        Icons.edit,
                                                        color: Colors.black87,
                                                      ),
                                                    ))
                                                  : _followButton()),
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
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          title: FadeTransition(
                              opacity: CurvedAnimation(
                                  parent: _controller,
                                  curve: Interval(.85, 1.0)),
                              child:
                                  Text("${user.firstname} ${user.lastname}")),
                          leading: IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                if (_transitionController.isAnimating) return;
                                _transitionController.duration =
                                    Duration(milliseconds: 300);
                                _transitionController
                                    .reverse()
                                    .whenComplete(() {
                                  Navigator.pop(context);
                                });
                              }),
                        );
                      }),
                ),
              ]);
            }));
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
        crossAxisAlignment: alignment,
        children: <Widget>[
          Text(
            number.toString(),
            style: _theme.accentTextTheme.title,
          ),
          Text(
            text,
            style: _theme.accentTextTheme.body1.copyWith(
                color: _theme.accentTextTheme.body1.color.withOpacity(.75)),
          )
        ],
      ),
    );
  }

  void _toggleFollow() async {
    if (_followed) {
      await DatabaseService(um.uid).deleteFollow(user);
    } else {
      await DatabaseService(um.uid).createFollow(user);
    }
  }

  Widget _followButton() {
    return StreamBuilder<bool>(
        stream: DatabaseService(um.uid).getFollowStream(user),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _followed = snapshot.data;
            _followController.animateTo(_followed ? 1.0 : 0.0);
          }

          return Center(
              child: AnimatedBuilder(
                  animation: _followController,
                  builder: (context, child) {
                    return FloatingActionButton(
                      elevation: 0,
                      backgroundColor:
                          ColorTween(begin: Colors.white, end: Colors.red)
                              .animate(_followController)
                              .value,
                      onPressed: snapshot.hasData ? _toggleFollow : null,
                      child: Transform.rotate(
                          angle: Tween<double>(begin: 0, end: degreesToRads(45))
                              .animate(CurvedAnimation(
                                parent: _followController,
                                curve: Curves.easeOut,
                              ))
                              .value,
                          child: Icon(
                            Icons.add,
                            color: ColorTween(
                                    begin: Colors.black87, end: Colors.white)
                                .animate(_followController)
                                .value,
                          )),
                    );
                  }));
        });
  }

  double degreesToRads(double deg) {
    return (deg * pi) / 180.0;
  }

  List<Widget> _generateChildren() {
    List<Widget> list = [];

    list.add(SizedBox(
      height: _headerHeight - 20 - mq.padding.top,
    ));

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
