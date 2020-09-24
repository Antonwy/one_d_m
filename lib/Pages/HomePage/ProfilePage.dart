import 'package:flutter/material.dart';
import 'package:one_d_m/Components/ActivityDonationFeed.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Components/BottomDialog.dart';
import 'package:one_d_m/Components/CustomOpenContainer.dart';
import 'package:one_d_m/Components/DailyReportFeed.dart';
import 'package:one_d_m/Components/InfoFeed.dart';
import 'package:one_d_m/Components/RoundButtonHomePage.dart';
import 'package:one_d_m/Components/SettingsDialog.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Numeral.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/CreateCampaignPage.dart';
import 'package:one_d_m/Pages/PaymentInfosPage.dart';
import 'package:one_d_m/Pages/RewardVideoPage.dart';
import 'package:one_d_m/Pages/UserPage.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  Function goToExplore;

  ProfilePage(this.goToExplore);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  ThemeData _theme;
  BaseTheme _bTheme;

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    _bTheme = ThemeManager.of(context).theme;
    return CustomScrollView(
      slivers: <Widget>[
        Consumer<UserManager>(
          builder: (context, um, child) => StreamBuilder<User>(
              initialData: um.user,
              stream: DatabaseService.getUserStream(um.uid),
              builder: (context, snapshot) {
                User user = snapshot.data;
                return SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  actions: <Widget>[],
                  bottom: PreferredSize(
                    preferredSize: Size(MediaQuery.of(context).size.width, 110),
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
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
                                      style: _theme.textTheme.headline5
                                          .copyWith(
                                              fontSize: 32,
                                              color: _bTheme.dark),
                                    ),
                                    Text(
                                      "${user?.name}",
                                      style: _theme.textTheme.headline5
                                          .copyWith(
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                              color: _bTheme.dark),
                                    ),
                                  ],
                                ),
                                Container(
                                  child: CustomOpenContainer(
                                    openBuilder: (context, close, controller) =>
                                        UserPage(user,
                                            scrollController: controller),
                                    closedShape: CircleBorder(),
                                    closedElevation: 0,
                                    closedBuilder: (context, open) => Avatar(
                                      user?.thumbnailUrl ?? user?.imgUrl,
                                      onTap: open,
                                    ),
                                  ),
                                  width: 60,
                                  height: 60,
                                ),
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
                                      "Gespendet: ",
                                      style: TextStyle(
                                          fontSize: 15, color: _bTheme.dark),
                                    ),
                                    Text(
                                      "${Numeral(user?.donatedAmount ?? 0).value()} DC",
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: _bTheme.dark),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    CustomOpenContainer(
                                      openBuilder:
                                          (context, close, controller) =>
                                              PaymentInfosPage(
                                                  scrollController: controller),
                                      closedShape: CircleBorder(),
                                      closedElevation: 0,
                                      closedColor: _bTheme.contrast,
                                      closedBuilder: (context, open) =>
                                          RoundButtonHomePage(
                                        icon: Icons
                                            .credit_card, // toPage: BuyCoinsPage(),
                                        // toPage: BuyCoinsPage(),
                                        onTap: () {
                                          open();
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    CustomOpenContainer(
                                      openBuilder:
                                          (context, close, controller) =>
                                              RewardVideoPage(),
                                      closedShape: CircleBorder(),
                                      closedElevation: 0,
                                      closedColor: ColorTheme.orange,
                                      closedBuilder: (context, open) =>
                                          RoundButtonHomePage(
                                        icon: Icons.play_arrow,
                                        onTap: open,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    CustomOpenContainer(
                                      openBuilder:
                                          (context, close, controller) =>
                                              UserPage(user,
                                                  scrollController: controller),
                                      closedShape: CircleBorder(),
                                      closedElevation: 0,
                                      closedColor: _bTheme.contrast,
                                      closedBuilder: (context, open) =>
                                          RoundButtonHomePage(
                                        icon: Icons.person,
                                        onTap: open,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        user?.admin ?? false
                                            ? RoundButtonHomePage(
                                                icon: Icons.add,
                                                toPage: CreateCampaignPage(),
                                                toColor: Colors.indigo,
                                              )
                                            : Container(
                                                width: 0,
                                              ),
                                        user?.admin ?? false
                                            ? SizedBox(
                                                width: 10,
                                              )
                                            : Container(
                                                width: 0,
                                              ),
                                      ],
                                    ),
                                    RoundButtonHomePage(
                                      icon: Icons.settings,
                                      onTap: () {
                                        BottomDialog(context)
                                            .show(SettingsDialog());
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
                );
              }),
        ),
        InfoFeed(),
        ChangeNotifierProvider.value(
            value: DailyReportManager(), child: DailyReportFeed()),
        ChangeNotifierProvider.value(
            value: DailyReportManager(), child: ActivityDonationFeed()),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
