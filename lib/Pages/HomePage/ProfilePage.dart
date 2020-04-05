import 'dart:math';

import 'package:flutter/material.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Components/BottomDialog.dart';
import 'package:one_d_m/Components/DonationWidget.dart';
import 'package:one_d_m/Components/NewsPost.dart';
import 'package:one_d_m/Components/PercentIndicator.dart';
import 'package:one_d_m/Components/RoundButtonHomePage.dart';
import 'package:one_d_m/Components/SettingsDialog.dart';
import 'package:one_d_m/Components/UserPageRoute.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Donation.dart';
import 'package:one_d_m/Helper/DonationInfo.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/CreateCampaignPage.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  Function goToExplore;

  ProfilePage(this.goToExplore);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  Future<List<News>> _newsFuture;
  ThemeData _theme;

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: <Widget>[],
          bottom: PreferredSize(
            preferredSize: Size(MediaQuery.of(context).size.width, 130),
            child: Container(),
          ),
          flexibleSpace: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.0),
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
                          Consumer<UserManager>(
                            builder: (context, um, child) => Text(
                              "${um.user?.firstname} ${um.user?.lastname}",
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      Consumer<UserManager>(
                        builder: (context, um, child) => Container(
                          child: Avatar(
                            um.user?.imgUrl,
                            onTap: () {
                              Navigator.push(context, UserPageRoute(um.user));
                            },
                          ),
                          width: 60,
                          height: 60,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Consumer<UserManager>(builder: (context, um, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Gespendet: ",
                              style: TextStyle(fontSize: 15),
                            ),
                            Text(
                              "${um.user?.donatedAmount ?? 0} DC",
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ],
                        );
                      }),
                      Row(
                        children: <Widget>[
                          RoundButtonHomePage(
                            icon: Icons.attach_money, // toPage: BuyCoinsPage(),
                            // toPage: BuyCoinsPage(),
                            onTap: () {
                              DatabaseService().updateDatabaseDonations();
                            },
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Consumer<UserManager>(
                            builder: (context, um, child) => Row(
                              children: <Widget>[
                                um.user?.admin ?? false
                                    ? RoundButtonHomePage(
                                        icon: Icons.add,
                                        toPage: CreateCampaignPage(),
                                        toColor: Colors.indigo,
                                      )
                                    : Container(
                                        width: 0,
                                      ),
                                um.user?.admin ?? false
                                    ? SizedBox(
                                        width: 10,
                                      )
                                    : Container(
                                        width: 0,
                                      ),
                              ],
                            ),
                          ),
                          RoundButtonHomePage(
                            icon: Icons.settings,
                            onTap: () {
                              BottomDialog(context).show(SettingsDialog());
                            },
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
        Consumer<UserManager>(builder: (context, um, child) {
          if (um.user != null)
            _newsFuture = _newsFuture ?? DatabaseService().getNews(um.user);
          return FutureBuilder<List<News>>(
            future: _newsFuture,
            builder: (BuildContext c, AsyncSnapshot<List<News>> snapshot) {
              if (snapshot.hasData) {
                return SliverList(
                    delegate: SliverChildListDelegate(
                        _generateChildren(snapshot.data)));
              }
              return SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  List<Widget> _generateChildren(List<News> data) {
    List<Widget> list = [];

    list.addAll(_showGeneralDonationFeed());

    list.addAll(_showDonationFeed());

    if (data.isNotEmpty) {
      list.add(Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        child: Text(
          "Neuigkeiten:",
          style: _theme.textTheme.title,
        ),
      ));
      data.sort((n1, n2) => n2.createdAt.compareTo(n1.createdAt));
      for (News n in data) {
        list.add(NewsPost(n));
      }
      list.add(SizedBox(
        height: 100,
      ));
      return list;
    }

    list.add(Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Image.asset("assets/images/clip-1.png"),
        Text(
          "Noch keine Neuigkeiten!",
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
        ),
        SizedBox(
          height: 110,
        )
      ],
    ));

    return list;
  }

  List<Widget> _showGeneralDonationFeed() {
    return [
      StreamBuilder<DonationInfo>(
          stream: DatabaseService().getDonationInfo(),
          builder: (context, snapshot) {
            DonationInfo di = snapshot.data;

            if (!snapshot.hasData)
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  child: Text(
                    "Unsere Ziele:",
                    style: _theme.textTheme.title,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    PercentIndicator(
                      currentValue: di.dailyAmount,
                      targetValue: di.dailyAmountTarget,
                      color: Colors.indigo,
                      description: "Tagesziel",
                    ),
                    PercentIndicator(
                      currentValue: di.monthlyAmount,
                      targetValue: di.monthlyAmountTarget,
                      color: Colors.red,
                      description: "Monatsziel",
                    ),
                    PercentIndicator(
                      currentValue: di.yearlyAmount,
                      targetValue: di.yearlyAmountTarget,
                      color: Colors.orange,
                      description: "Jahresziel",
                    ),
                  ],
                ),
              ],
            );
          })
    ];
  }

  List<Widget> _showDonationFeed() {
    return [
      Consumer<UserManager>(
        builder: (context, um, child) => StreamBuilder<List<Donation>>(
          stream: DatabaseService(um.uid).getDonationFeedStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.isEmpty) return Container();
              print(snapshot.data);
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Aktivitäten: ",
                      style: _theme.textTheme.title,
                    ),
                    SizedBox(height: 5),
                    ...snapshot.data
                        .map((d) => DonationWidget(d, withCampaignName: true))
                  ],
                ),
              );
            }

            return Center(child: CircularProgressIndicator());
          },
        ),
      )
    ];
  }

  @override
  bool get wantKeepAlive => true;
}
