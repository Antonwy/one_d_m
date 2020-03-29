import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/AnimatedFutureBuilder.dart';
import 'package:one_d_m/Components/CampaignList.dart';
import 'package:one_d_m/Components/SearchBar.dart';
import 'package:one_d_m/Components/UserAvatar.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/CircularRevealRoute.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Pages/UserPage.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  TextTheme textTheme;
  Future _queryFuture;

  List<Campaign> campaigns;

  @override
  void initState() {
    _queryFuture = DatabaseService().getCampaignFromQuery("");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    textTheme = Theme.of(context).textTheme;

    return NestedScrollView(
      headerSliverBuilder: (context, b) => [
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
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text("Entdecken", style: textTheme.title),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SearchBar(onChanged: (String text) {
                    setState(() {
                      _queryFuture =
                          DatabaseService().getCampaignFromQuery(text);
                    });
                  }),
                ),
                SizedBox(height: 20),
                AnimatedFutureBuilder<List<User>>(
                    future: DatabaseService().getUsers(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.isEmpty) return Container();
                        return Container(
                          height: 110,
                          child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: _buildUserAvatars(snapshot.data)),
                        );
                      }
                      return Container(height: 110,);
                    })
              ],
            ),
          ),
        ),
      ],
      body: CampaignList(
        campaignsFuture: _queryFuture,
      ),
    );
  }

  List<Widget> _buildUserAvatars(List<User> users) {
    List<Widget> list = [];

    list.add(SizedBox(width: 20));

    for (User user in users) {
      list.add(UserAvatar(user));
      list.add(SizedBox(
        width: 20,
      ));
    }

    return list;
  }
}
