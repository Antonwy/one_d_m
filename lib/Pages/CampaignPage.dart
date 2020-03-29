import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/AnimatedFutureBuilder.dart';
import 'package:one_d_m/Components/DonationDialog.dart';

import 'package:one_d_m/Components/NewsBody.dart';
import 'package:one_d_m/Components/UserPageRoute.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/RectRevealRoute.dart';
import 'package:one_d_m/Helper/User.dart';

import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/CreateNewsPage.dart';
import 'package:one_d_m/Pages/UserPage.dart';
import 'package:provider/provider.dart';

class CampaignPage extends StatefulWidget {
  Campaign campaign;

  CampaignPage(this.campaign);

  @override
  _CampaignPageState createState() => _CampaignPageState();
}

class _CampaignPageState extends State<CampaignPage>
    with TickerProviderStateMixin {
  ThemeData theme;
  AnimationController _transitionAnim;

  UserManager um;
  Size displaySize;
  Campaign campaign;
  Future<Campaign> _future;
  bool _subscribed = false, _isOwnPage = false, _loading = false;
  String _imgUrl;
  ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  GlobalKey _fabKey = GlobalKey();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Curve _transitionCurve = ElasticOutCurve(1.4);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _transitionAnim =
        AnimationController(vsync: this, duration: Duration(milliseconds: 750))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed)
              _transitionCurve = Curves.easeOut;
          })
          ..addListener(() {
            setState(() {});
          });

    _transitionAnim.forward();

    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });

    if (widget.campaign.description == null) {
      _future = DatabaseService().getCampaign(widget.campaign.id);
    } else {
      _future = Future.value(widget.campaign);
    }

    _imgUrl = widget.campaign.imgUrl;

    _future.then((Campaign c) {
      setState(() {
        _isOwnPage = c.authorId == um.uid;
        _imgUrl = c.imgUrl;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    um = Provider.of<UserManager>(context);
    displaySize = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ColorTween(
              begin: Colors.white.withOpacity(0), end: Colors.white)
          .animate(
              CurvedAnimation(parent: _transitionAnim, curve: Interval(.1, .2)))
          .value,
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(
            parent: _transitionAnim,
            curve: Interval(.5, 1.0, curve: _transitionCurve)),
        child: FloatingActionButton.extended(
          key: _fabKey,
          onPressed: () {
            if (_isOwnPage) {
              Navigator.push(
                  context,
                  RectRevealRoute(
                      page: CreateNewsPage(campaign),
                      offset: Helper.getCenteredPositionFromKey(_fabKey),
                      startSize: Helper.getSizeFromKey(_fabKey),
                      startRadius: 24,
                      duration: Duration(milliseconds: 750),
                      color: theme.primaryColor,
                      startColor: theme.primaryColor));
            } else {
              _showCoins();
            }
          },
          label: Text(_isOwnPage ? "Post erstellen" : "Spenden"),
          icon: _isOwnPage ? Icon(Icons.create) : null,
        ),
      ),
      body: FadeTransition(
        opacity:
            CurvedAnimation(parent: _transitionAnim, curve: Interval(0.0, .2)),
        child: Stack(
          children: <Widget>[
            Positioned(
                top: _transitionAnim.isAnimating
                    ? Tween<double>(begin: -(displaySize.height * .35), end: 0)
                        .animate(CurvedAnimation(
                            parent: _transitionAnim,
                            curve: Interval(0.0, .8, curve: _transitionCurve)))
                        .value
                    : _scrollOffset < 0 ? 0 : -_scrollOffset * .3,
                width: displaySize.width,
                child: Container(
                  height: displaySize.height * .35 -
                      (_scrollOffset < 0 ? _scrollOffset : 0),
                  width: displaySize.width -
                      (_scrollOffset < 0 ? _scrollOffset : 0),
                  child: _imgUrl != null
                      ? Image(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(
                            _imgUrl,
                          ),
                        )
                      : Material(
                          color: Colors.grey[300],
                          child: Center(child: CircularProgressIndicator())),
                )),
            Positioned(
              width: displaySize.width,
              height: displaySize.height,
              bottom: Tween<double>(
                      begin: -((displaySize.height * .65) + 45), end: 0)
                  .animate(CurvedAnimation(
                      parent: _transitionAnim,
                      curve: Interval(0.1, 1, curve: _transitionCurve)))
                  .value,
              child: FutureBuilder<Campaign>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      campaign = snapshot.data;
                      _isOwnPage = campaign.authorId == um.uid;
                      return SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: displaySize.height * .35 - 45),
                            Material(
                              color: Colors.white,
                              clipBehavior: Clip.antiAlias,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30)),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(25, 10, 25, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      height: 10,
                                    ),
                                    _showAuthorAndDate(),
                                    SizedBox(height: 5),
                                    Text(
                                      campaign.name,
                                      style: theme.textTheme.title.copyWith(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    _isOwnPage
                                        ? Container()
                                        : Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:
                                                Center(child: _followButton()),
                                          ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    _campaignDetails(),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      campaign.description,
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 18),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    StreamBuilder<List<News>>(
                                        stream: DatabaseService()
                                            .getNewsFromCampaignStream(
                                                campaign),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            if (snapshot.data.isEmpty)
                                              return Container();
                                            return _generateNews(snapshot.data);
                                          }

                                          return Container();
                                        }),
                                    SizedBox(
                                      height: 100,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return Center(child: CircularProgressIndicator());
                  }),
            ),
            Positioned(
              left: 20,
              child: ScaleTransition(
                scale: CurvedAnimation(
                    parent: _transitionAnim,
                    curve: Interval(.2, .8, curve: _transitionCurve)),
                child: SafeArea(
                  child: Material(
                    clipBehavior: Clip.antiAlias,
                    elevation: 10,
                    shape: CircleBorder(),
                    child: InkWell(
                      onTap: () {
                        if (_transitionAnim.isAnimating) return;
                        _transitionAnim.duration = Duration(milliseconds: 350);
                        _transitionAnim.reverse().whenComplete(() {
                          Navigator.pop(context);
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(10, 12, 12, 12),
                        child: Icon(Icons.close),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _isOwnPage
                ? Positioned(
                    right: 20,
                    child: ScaleTransition(
                      scale: CurvedAnimation(
                          parent: _transitionAnim,
                          curve: Interval(.4, 1, curve: _transitionCurve)),
                      child: SafeArea(
                        child: Material(
                          clipBehavior: Clip.antiAlias,
                          elevation: 10,
                          shape: CircleBorder(),
                          child: InkWell(
                            onTap: _deleteCampaign,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(10, 12, 12, 12),
                              child: _loading
                                  ? CircularProgressIndicator()
                                  : Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  void _showCoins() {
    DonationDialog.of(context).show();
  }

  Widget _followButton() {
    return StreamBuilder<DocumentSnapshot>(
        stream: DatabaseService(um.uid).hasSubscribedCampaign(campaign.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _subscribed = snapshot.data.exists;
            return RaisedButton(
              onPressed: _toggleSubscribed,
              color: _subscribed ? Colors.red : theme.primaryColor,
              child: Text(
                _subscribed ? "Entfolgen" : "Folgen",
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            return RaisedButton(
              onPressed: null,
              color: theme.primaryColor,
              child: Text("Laden...", style: TextStyle(color: Colors.white)),
            );
          }
        });
  }

  _deleteCampaign() async {
    if (await showDialog(
        context: context,
        child: AlertDialog(
          title: Text(
            "Löschen",
            style: TextStyle(color: Colors.red),
          ),
          content: Text(
              "Bist du dir sicher, dass du ${campaign.name} löschen willst?"),
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text("Abbrechen")),
            FlatButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text(
                  "Löschen",
                  style: TextStyle(color: Colors.red),
                )),
          ],
        ))) {
      setState(() {
        _loading = true;
      });
      await DatabaseService().deleteCampaign(campaign);
      Navigator.pop(context);
    }
  }

  void _toggleSubscribed() {
    if (_subscribed)
      DatabaseService(um.uid).deleteSubscription(campaign);
    else
      DatabaseService(um.uid).createSubscription(campaign);
  }

  Widget _generateNews(List<News> news) {
    List<Widget> widgets = [];

    widgets.add(Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
          child: Text(
            "News: ",
            style: theme.textTheme.title,
          ),
        )));

    for (News n in news) {
      widgets.add(NewsBody(
        n,
        isHero: false,
      ));
    }

    return Column(
      children: widgets,
    );
  }

  Widget _details({IconData icon, String text}) => Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 35,
            ),
            SizedBox(height: 10),
            Text(
              text,
            ),
          ],
        ),
      );

  Widget _showAuthorAndDate() {
    return AnimatedFutureBuilder<User>(
        future: DatabaseService(campaign.authorId).getUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            User user = snapshot.data;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, UserPageRoute(user));
                  },
                  child: Text(
                    "${user.firstname} ${user.lastname}",
                    style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
                Text(Helper.getDate(campaign.createdAt))
              ],
            );
          }
          return Container(
            height: 20,
            width: 10,
          );
        });
  }

  Widget _campaignDetails() {
    return Container(
      width: displaySize.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _details(icon: Icons.location_on, text: campaign.city.split(",")[0]),
          _details(
              icon: Icons.monetization_on, text: "${campaign.amount} Coins"),
          _details(icon: Icons.people, text: "1400 Mitglieder"),
        ],
      ),
    );
  }
}
