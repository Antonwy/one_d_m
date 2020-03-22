import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/NewsPost.dart';
import 'package:one_d_m/Components/RoundButtonHomePage.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/CreateCampaignPage.dart';
import 'package:one_d_m/Pages/BuyCoinsPage.dart';
import 'package:one_d_m/Pages/SettingsPage.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  Function goToExplore;

  ProfilePage(this.goToExplore);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserManager um;

  @override
  Widget build(BuildContext context) {
    um = Provider.of<UserManager>(context);

    return NestedScrollView(
      headerSliverBuilder: (context, b) => [
        SliverAppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: <Widget>[],
          bottom: PreferredSize(
            preferredSize: Size(MediaQuery.of(context).size.width, 140),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Willkommen,",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.w200),
                          ),
                          Text(
                            "${um.user?.firstname} ${um.user?.lastname}",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        child:
                            um.user.imgUrl != null ? null : Icon(Icons.person),
                        radius: 30,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: um.user.imgUrl == null
                            ? null
                            : CachedNetworkImageProvider(um.user.imgUrl),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Dein Guthaben: ",
                            style: TextStyle(fontSize: 15),
                          ),
                          Text(
                            "25 Coins",
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          RoundButtonHomePage(
                              icon: Icons.attach_money, toPage: BuyCoinsPage()),
                          SizedBox(
                            width: 10,
                          ),
                          RoundButtonHomePage(
                            icon: Icons.add,
                            toPage: CreateCampaignPage(),
                            toColor: Colors.indigo,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          RoundButtonHomePage(
                            icon: Icons.settings,
                            toPage: SettingsPage(),
                          )
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ],
      body: FutureBuilder<List<News>>(
        future: DatabaseService(um.uid).getNews(),
        builder: (BuildContext c, AsyncSnapshot<List<News>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.isEmpty)
              return Column(
                children: <Widget>[
                  SizedBox(height: 50),
                  Image.asset("assets/images/clip-1.png"),
                  Text(
                    "Du folgst noch keinen Projekte!",
                    style: Theme.of(context).textTheme.body2,
                  ),
                  SizedBox(height: 10),
                  RaisedButton(
                    onPressed: widget.goToExplore,
                    child: Text(
                      "Entdecke Projekte!",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Theme.of(context).primaryColor,
                  )
                ],
              );

            return ListView(children: _generateChildren(snapshot.data));
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  List<Widget> _generateChildren(List<News> data) {
    List<Widget> list = [];

    for (News n in data) {
      list.add(NewsPost(n));
    }

    list.add(SizedBox(
      height: 100,
    ));

    return list;
  }
}
