import 'package:flutter/material.dart';
import 'package:one_d_m/Components/ActivityDonationFeed.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Components/BottomDialog.dart';
import 'package:one_d_m/Components/GeneralDonationFeed.dart';
import 'package:one_d_m/Components/RoundButtonHomePage.dart';
import 'package:one_d_m/Components/SettingsDialog.dart';
import 'package:one_d_m/Components/UserPageRoute.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/CreateCampaignPage.dart';
import 'package:one_d_m/Pages/PaymentInfosPage.dart';
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
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: <Widget>[],
          bottom: PreferredSize(
            preferredSize: Size(MediaQuery.of(context).size.width, 110),
            child: SafeArea(
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
                                  fontSize: 30, fontWeight: FontWeight.w300),
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
                              um.user?.thumbnailUrl ?? um.user.imgUrl,
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
                              icon:
                                  Icons.credit_card, // toPage: BuyCoinsPage(),
                              // toPage: BuyCoinsPage(),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (c) => PaymentInfosPage()));
                              },
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Consumer<UserManager>(
                                builder: (context, um, child) {
                              return RoundButtonHomePage(
                                icon: Icons.person,
                                onTap: () {
                                  Navigator.push(
                                      context, UserPageRoute(um.user));
                                },
                              );
                            }),
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
        ),
        SliverList(
            delegate: SliverChildListDelegate([
          GeneralDonationFeed(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              "Spenden ",
              style: Theme.of(context).textTheme.title,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              "Das haben deine Freunde in letzter Zeit gespendet:",
              style: Theme.of(context).textTheme.body1,
            ),
          ),
        ])),
        ActivityDonationFeed(),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
