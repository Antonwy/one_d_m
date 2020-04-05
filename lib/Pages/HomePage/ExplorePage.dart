import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/AnimatedFutureBuilder.dart';
import 'package:one_d_m/Components/CampaignList.dart';
import 'package:one_d_m/Components/SearchBar.dart';
import 'package:one_d_m/Components/UserAvatar.dart';
import 'package:one_d_m/Helper/CampaignsManager.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:provider/provider.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with AutomaticKeepAliveClientMixin {
  TextTheme textTheme;

  Future<List<User>> _userFuture;

  @override
  void initState() {
    _userFuture = DatabaseService().getUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    textTheme = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: Colors.white,
          centerTitle: false,
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: Size(0, 200),
            child: Container(),
          ),
          flexibleSpace: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Text("Entdecken", style: textTheme.title),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: SearchBar(),
                ),
                SizedBox(height: 20),
                AnimatedFutureBuilder<List<User>>(
                    future: _userFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data.isEmpty)
                        return Container();
                      return Container(
                        height: 110,
                        child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: snapshot.hasData
                                ? _buildUserAvatars(snapshot.data)
                                : _buildUserAvatars(
                                    List.generate(10, (i) => User()))),
                      );
                    })
              ],
            ),
          ),
        ),
        Consumer<CampaignsManager>(
            builder: (context, cm, child) => CampaignList(
                  campaigns: cm.getAllCampaigns(),
                ))
      ],
    );
  }

  List<Widget> _buildUserAvatars(List<User> users) {
    List<Widget> list = [];

    list.add(SizedBox(width: 18));

    for (User user in users) {
      list.add(UserAvatar(user));
      list.add(SizedBox(
        width: 18,
      ));
    }

    return list;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
