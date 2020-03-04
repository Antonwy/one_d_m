import 'package:flutter/material.dart';
import 'package:one_d_m/Components/CampaignHeader.dart';
import 'package:one_d_m/Helper/API/Api.dart';
import 'package:one_d_m/Helper/API/ApiResult.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/User.dart';

import 'HomePage/HomePage.dart';

class UserPage extends StatefulWidget {
  User user;

  UserPage(this.user);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  Future<ApiResult<List<Campaign>>> _future;

  bool _followed = false;

  @override
  void initState() {
    super.initState();
    _future = Api.getCampaignsFromUserId(widget.user.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
          onRefresh: () {
            Future<ApiResult> res = Api.getCampaignsFromUserId(widget.user.id);
            setState(() {
              _future = res;
            });
            return res;
          },
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                automaticallyImplyLeading: false,
                actions: <Widget>[],
                bottom: PreferredSize(
                  preferredSize: Size(MediaQuery.of(context).size.width, 150),
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Container();
                  }),
                ),
                flexibleSpace: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "${widget.user?.firstname} ${widget.user?.lastname}",
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.w500),
                            ),
                            CircleAvatar(
                              child: Icon(Icons.person),
                              radius: 30,
                              backgroundColor: Colors.grey[200],
                            )
                          ],
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                          children: <Widget>[
                            _roundButtons(
                                text: _followed ? "Entfolgen" : "Folgen",
                                onPressed: _toggleFollow,
                                color: _followed
                                    ? Colors.red
                                    : Theme.of(context).primaryColor),
                            SizedBox(width: 10),
                            _roundButtons(
                                text: "Nachricht",
                                onPressed: () {},
                                color: Theme.of(context).primaryColor),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              FutureBuilder<ApiResult>(
                future: _future,
                builder: (BuildContext c, AsyncSnapshot<ApiResult> snapshot) {
                  if (snapshot.hasData) {
                    return SliverList(
                      delegate: SliverChildListDelegate(
                          _generateChildren(snapshot.data.getData())),
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
          )),
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

  void _toggleFollow() {
    setState(() {
      _followed = !_followed;
    });
  }

  Widget _roundButtons({String text, Function onPressed, Color color}) {
    return Expanded(
        child: MaterialButton(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 8,
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(color: Colors.white),
      ),
    ));
  }

  List<Widget> _generateChildren(List<Campaign> data) {
    List<Widget> list = [];

    list.add(Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Text(
        "Projekte: ",
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
