import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/CampaignHeader.dart';
import 'package:one_d_m/Helper/API/ApiResult.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/FollowersListPage.dart';
import 'package:provider/provider.dart';

import 'HomePage/HomePage.dart';

class UserPage extends StatefulWidget {
  User user;

  UserPage(this.user);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool _followed = false;
  bool _isOwnPage = false;

  ThemeData _theme;
  UserManager um;

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    um = Provider.of<UserManager>(context);
    _isOwnPage = widget.user.id == um.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: _theme.iconTheme.copyWith(color: Colors.black87),
            bottom: PreferredSize(
                preferredSize: Size(
                    MediaQuery.of(context).size.width, _isOwnPage ? 220 : 260),
                child: Container()),
            flexibleSpace: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        _followersCollumn(
                            text: "Abonnenten",
                            stream: DatabaseService()
                                .getFollowedUsersStream(widget.user)),
                        CircleAvatar(
                          child: widget.user.imgUrl == null
                              ? Icon(Icons.person)
                              : null,
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: widget.user.imgUrl == null
                              ? null
                              : CachedNetworkImageProvider(widget.user.imgUrl),
                        ),
                        _followersCollumn(
                            text: "Abonniert",
                            stream: DatabaseService()
                                .getFollowingUsersStream(widget.user)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "${widget.user?.firstname} ${widget.user?.lastname}",
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 30,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  _isOwnPage ? Container() : _roundButtons(),
                  SizedBox(height: 10),
                  Divider(),
                ],
              ),
            ),
          ),
          StreamBuilder<List<Campaign>>(
            stream:
                DatabaseService(widget.user.id).getSubscribedCampaignsStream(),
            builder: (BuildContext c, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.isEmpty) {
                  return SliverFillRemaining(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          height: 40,
                        ),
                        Image.asset("assets/images/clip-no-comments.png"),
                        Text("Du hast noch keine Projekte abonniert!"),
                      ],
                    ),
                  );
                }
                return SliverList(
                  delegate:
                      SliverChildListDelegate(_generateChildren(snapshot.data)),
                );
              }
              return SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (c) => HomePage()));
        },
        icon: Icon(Icons.home),
        label: Text("Back home"),
      ),
    );
  }

  Widget _followersCollumn({String text, Stream stream}) {
    return StreamBuilder<List<User>>(
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
        });
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
          return RaisedButton(
            color: _followed ? Colors.red : Colors.indigo,
            onPressed: snapshot.hasData ? _toggleFollow : null,
            child: Text(
              text,
              style: TextStyle(color: Colors.white),
            ),
          );
        });
  }

  List<Widget> _generateChildren(List<Campaign> data) {
    List<Widget> list = [];

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

    list.add(SizedBox(
      height: 100,
    ));

    return list;
  }
}
