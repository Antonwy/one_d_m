import 'package:flutter/material.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Components/CampaignHeader.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/EditProfile.dart';
import 'package:one_d_m/Pages/FollowersListPage.dart';
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

  double _headerHeight = 300, _headerTop = 5, _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    _transitionController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300))
          ..forward();

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset;
          _controller.value = Helper.mapValue(_scrollOffset, 0, 220, 0, 1);
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    um = Provider.of<UserManager>(context);
    _isOwnPage = widget.user.id == um.uid;
    mq = MediaQuery.of(context);

    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(overflow: Overflow.clip, children: <Widget>[
          Positioned(
            height: mq.size.height,
            width: mq.size.width,
            top: 0,
            child: FadeTransition(
              opacity: CurvedAnimation(
                  parent: _transitionController, curve: Interval(0.0, 1.0)),
              child: Container(
                color: Colors.white,
                child: FutureBuilder<List<Campaign>>(
                  future:
                      DatabaseService(widget.user.id).getSubscribedCampaigns(),
                  builder: (BuildContext c, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.isEmpty) {
                        return Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Image.asset("assets/images/clip-no-comments.png"),
                              Text("Du hast noch keine Projekte abonniert!"),
                              SizedBox(
                                height: 40,
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView(
                        controller: _scrollController,
                        children: _generateChildren(snapshot.data),
                      );
                    }
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        child: CircularProgressIndicator(),
                        padding: EdgeInsets.only(bottom: 40),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          AnimatedBuilder(
              animation: _transitionController,
              builder: (context, snapshot) {
                return Positioned(
                  top: Tween(
                          begin: -(_headerHeight + _headerTop + mq.padding.top),
                          end: 0.0)
                      .animate(CurvedAnimation(
                          parent: _transitionController,
                          curve: ElasticOutCurve(1.4)))
                      .value,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 10))
                            ],
                            borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(16))),
                        child: ClipRect(
                          child: Align(
                            heightFactor: Tween(
                                    begin: 1.0,
                                    end: 80 / (_headerHeight + _headerTop))
                                .animate(_controller)
                                .value,
                            child: Container(
                              height: _headerHeight + mq.padding.top,
                              width: mq.size.width,
                              padding: EdgeInsets.only(
                                  top: mq.padding.top + _headerTop),
                              child: Stack(
                                children: <Widget>[
                                  Positioned(
                                    top: 40,
                                    left: 0,
                                    right: 0,
                                    child: Opacity(
                                      opacity: Tween(begin: 1.0, end: 0.0)
                                          .animate(CurvedAnimation(
                                              parent: _controller,
                                              curve: Interval(.5, 1.0)))
                                          .value,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            _followersCollumn(
                                                text: "Abonnenten",
                                                stream: DatabaseService()
                                                    .getFollowedUsersStream(
                                                        widget.user)),
                                            Container(
                                              height: 120,
                                              width: 120,
                                              child: Avatar(
                                                widget.user.imgUrl,
                                              ),
                                            ),
                                            _followersCollumn(
                                                text: "Abonniert",
                                                stream: DatabaseService()
                                                    .getFollowingUsersStream(
                                                        widget.user)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: Tween(begin: 170.0, end: 112.0)
                                        .animate(_controller)
                                        .value,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: Text(
                                        "${widget.user?.firstname} ${widget.user?.lastname}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 30,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                      top: 210.0,
                                      left: 0,
                                      right: 0,
                                      child: Opacity(
                                          opacity: 1 - _controller.value,
                                          child: _isOwnPage
                                              ? Center(
                                                  child: RaisedButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (c) =>
                                                                EditProfile()));
                                                  },
                                                  child: Text("Bearbeiten"),
                                                  color: Colors.indigo,
                                                  textColor: Colors.white,
                                                ))
                                              : _roundButtons())),
                                ],
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
              top: mq.padding.top,
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black87,
                    ),
                    onPressed: () {
                      if (_transitionController.isAnimating) return;
                      _transitionController.reverse().whenComplete(() {
                        Navigator.pop(context);
                      });
                    }),
              )),
        ]));
  }

  Widget _followersCollumn({String text, Stream stream}) {
    return Container(
      height: 57,
      child: StreamBuilder<List<User>>(
          stream: stream,
          builder: (context, snapshot) {
            return InkWell(
              onTap: snapshot.hasData && snapshot.data.isNotEmpty
                  ? () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) => FollowersListPage(
                                    title: text,
                                    users: snapshot.data,
                                  )));
                    }
                  : null,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      snapshot.hasData ? snapshot.data.length.toString() : "0",
                      style: _theme.textTheme.title,
                    ),
                    Text(text)
                  ],
                ),
              ),
            );
          }),
    );
  }

  void _toggleFollow() async {
    if (_followed) {
      await DatabaseService(um.uid).deleteFollow(widget.user);
    } else {
      await DatabaseService(um.uid).createFollow(widget.user);
    }
  }

  Widget _roundButtons() {
    return StreamBuilder<bool>(
        stream: DatabaseService(um.uid).getFollowStream(widget.user),
        builder: (context, snapshot) {
          String text = "Laden...";
          if (snapshot.hasData) {
            _followed = snapshot.data;
            text = _followed ? "Entfolgen" : "Folgen";
          }
          return Center(
            child: RaisedButton(
              color: _followed ? Colors.red : Colors.indigo,
              onPressed: snapshot.hasData ? _toggleFollow : null,
              child: Text(
                text,
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        });
  }

  List<Widget> _generateChildren(List<Campaign> data) {
    List<Widget> list = [];

    list.add(SizedBox(
      height: _headerHeight + _headerTop + 20,
    ));

    list.add(Padding(
      padding: const EdgeInsets.only(left: 20.0, bottom: 10),
      child: Text(
        "Abonnierte Projekte: ",
        style: Theme.of(context).textTheme.headline,
      ),
    ));

    for (Campaign c in data) {
      list.add(CampaignHeader(c));
    }

    list.add(SizedBox(height: mq.size.height * .5));

    return list;
  }
}
