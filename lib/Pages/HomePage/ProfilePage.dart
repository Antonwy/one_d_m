import 'package:flutter/material.dart';
import 'package:one_d_m/Components/NewsPost.dart';
import 'package:one_d_m/Components/RoundButtonHomePage.dart';
import 'package:one_d_m/Helper/API/Api.dart';
import 'package:one_d_m/Helper/API/ApiResult.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/CreateCampaignPage.dart';
import 'package:one_d_m/Pages/BuyCoinsPage.dart';
import 'package:one_d_m/Pages/SettingsPage.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with AutomaticKeepAliveClientMixin<ProfilePage> {
  UserManager um;

  Future<ApiResult> _future;

  @override
  void initState() {
    print("NOw");
    _future = Api.getNews();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    um = Provider.of<UserManager>(context);

    return RefreshIndicator(
        onRefresh: () {
          Future<ApiResult> res = Api.getNews();
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
                          um.hasData
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      "Willkommen,",
                                      style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w200),
                                    ),
                                    Text(
                                      "${um.user?.firstname} ${um.user?.lastname}",
                                      style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                )
                              : CircularProgressIndicator(),
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
                              RoundButtonHomePage(icon: Icons.attach_money, toPage: BuyCoinsPage()),
                              SizedBox(
                                width: 10,
                              ),
                              RoundButtonHomePage(icon: Icons.add, toPage: CreateCampaignPage(), toColor: Colors.indigo,),
                              SizedBox(
                                width: 10,
                              ),
                              RoundButtonHomePage(icon: Icons.settings, toPage: SettingsPage(),)
                            ],
                          ),
                        ],
                      )
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
        ));
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

  @override
  bool get wantKeepAlive => true;

}
