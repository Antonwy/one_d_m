import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/CampaignItem.dart';
import 'package:one_d_m/Helper/Api.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/CircularRevealRoute.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/AddPostPage.dart';
import 'package:one_d_m/Pages/BuyCoinsPage.dart';
import 'package:one_d_m/Pages/SettingsPage.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  final GlobalKey _coinsBtnKey = GlobalKey();
  final GlobalKey _addBtnKey = GlobalKey();
  final GlobalKey _settingsBtnKey = GlobalKey();

  final AsyncMemoizer<List<Campaign>> _asyncMemoizer = new AsyncMemoizer();

  UserManager um;

  @override
  Widget build(BuildContext context) {
    um = Provider.of<UserManager>(context);

    return RefreshIndicator(
        onRefresh: () => Future.delayed(Duration(seconds: 2)),
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
                              _roundButton(
                                  key: _coinsBtnKey,
                                  icon: Icons.attach_money,
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        CircularRevealRoute(
                                            page: BuyCoinsPage(),
                                            offset: Helper
                                                .getCenteredPositionFromKey(
                                                _addBtnKey),
                                            startColor: Colors.indigo,
                                            color: Colors.indigo));
                                  }),
                              SizedBox(
                                width: 10,
                              ),
                              _roundButton(
                                  key: _addBtnKey,
                                  icon: Icons.add,
                                  onPressed: () {
                                    print("Add");
                                    Navigator.push(
                                        context,
                                        CircularRevealRoute(
                                            page: AddPostPage(),
                                            offset: Helper
                                                .getCenteredPositionFromKey(
                                                    _addBtnKey),
                                            startColor: Colors.indigo,
                                            color: Colors.indigo));
                                  }),
                              SizedBox(
                                width: 10,
                              ),
                              _roundButton(
                                  key: _settingsBtnKey,
                                  icon: Icons.settings,
                                  onPressed: () {
                                    print("Settings");
                                    Navigator.push(
                                        context,
                                        CircularRevealRoute(
                                            page: SettingsPage(),
                                            offset: Helper
                                                .getCenteredPositionFromKey(
                                                    _settingsBtnKey),
                                            startColor: Colors.indigo,
                                            color: Colors.white));
                                  }),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            FutureBuilder<List<Campaign>>(
              future: _fetchData(),
              builder:
                  (BuildContext c, AsyncSnapshot<List<Campaign>> snapshot) {
                if (snapshot.hasData) {
                  return SliverList(
                    delegate: SliverChildListDelegate(
                        _generateChildren(snapshot.data)),
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

  Future<dynamic> _fetchData() {
    return this._asyncMemoizer.runOnce(() async {
      return await Api.getCampaigns();
    });
  }

  Widget _roundButton({Key key, IconData icon, void Function() onPressed}) {
    return Container(
      key: key,
      width: 50,
      height: 50,
      child: Material(
        clipBehavior: Clip.antiAlias,
        color: Colors.indigo,
        shape: CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  List<Widget> _generateChildren(List<Campaign> data) {
    List<Widget> list = [];

    for (Campaign c in data) {
      list.add(CampaignItem(c));
    }

    list.add(SizedBox(
      height: 100,
    ));

    return list;
  }
}
