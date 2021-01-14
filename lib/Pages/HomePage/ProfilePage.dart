import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/Components/ActivityDonationFeed.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Components/BottomDialog.dart';
import 'package:one_d_m/Components/CustomOpenContainer.dart';
import 'package:one_d_m/Components/DailyReportFeed.dart';
import 'package:one_d_m/Components/InfoFeed.dart';
import 'package:one_d_m/Components/RoundButtonHomePage.dart';
import 'package:one_d_m/Components/SessionsFeed.dart';
import 'package:one_d_m/Components/SettingsDialog.dart';
import 'package:one_d_m/Helper/CertifiedSessionsList.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Numeral.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/SessionInvitesFeed.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/CreateSessionPage.dart';
import 'package:one_d_m/Pages/RewardVideoPage.dart';
import 'package:one_d_m/Pages/SessionInvitesPage.dart';
import 'package:one_d_m/Pages/UserPage.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  ThemeManager _theme;
  Stream<List<BaseSession>> _sessionStream;
  Stream<List<BaseSession>> _certifiedSessionsStream;

  @override
  void initState() {
    String uid = Provider.of<UserManager>(context, listen: false).uid;
    _sessionStream = DatabaseService.getSessionsFromUser(uid);
    _certifiedSessionsStream =
        DatabaseService.getCertifiedSessionsFromUser(uid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
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
                                      style: _theme
                                          .materialTheme.textTheme.headline5
                                          .copyWith(
                                              fontSize: 32,
                                              color: _theme.colors.dark),
                                    ),
                                    Text(
                                      "${user?.name}",
                                      style: _theme
                                          .materialTheme.textTheme.headline5
                                          .copyWith(
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                              color: _theme.colors.dark),
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
                                          fontSize: 15,
                                          color: _theme.colors.dark),
                                    ),
                                    Text(
                                      "${Numeral(user?.donatedAmount ?? 0).value()} DV",
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: _theme.colors.dark),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    // CustomOpenContainer(
                                    //   openBuilder:
                                    //       (context, close, controller) =>
                                    //           PaymentInfosPage(
                                    //               scrollController: controller),
                                    //   closedShape: CircleBorder(),
                                    //   closedElevation: 0,
                                    //   closedColor: _bTheme.contrast,
                                    //   closedBuilder: (context, open) =>
                                    //       RoundButtonHomePage(
                                    //     icon: Icons
                                    //         .credit_card, // toPage: BuyCoinsPage(),
                                    //     // toPage: BuyCoinsPage(),
                                    //     onTap: () {
                                    //       open();
                                    //     },
                                    //   ),
                                    // ),
                                    // SizedBox(
                                    //   width: 10,
                                    // ),
                                    CustomOpenContainer(
                                      openBuilder:
                                          (context, close, controller) =>
                                              RewardVideoPage(),
                                      closedShape: CircleBorder(),
                                      closedElevation: 0,
                                      closedColor: _theme.colors.contrast,
                                      closedBuilder: (context, open) =>
                                          RoundButtonHomePage(
                                        icon: Icons.play_arrow,
                                        onTap: open,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
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
        StreamBuilder<List<Session>>(
          stream: _certifiedSessionsStream,
          builder: (context, snapshot1) => StreamBuilder<List<BaseSession>>(
              stream: _sessionStream,
              builder: (context, snapshot2) {
                List<BaseSession> sessions = snapshot2.data ?? [];
                List<BaseSession> certifiedSessions = snapshot1.data ?? [];

                if (sessions.isEmpty && certifiedSessions.isEmpty)
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _SessionInvitesButton(),
                              SizedBox(
                                width: 8,
                              ),
                              _CreateSessionButton()
                            ],
                          ),
                          SvgPicture.asset(
                            "assets/images/no-donations.svg",
                            height: 200,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Du bist momentan kein Mitglied einer Session.\nDrücke auf das + um eine eigene Session zu erstellen, oder trete einer öffentlichen bei!",
                            style: _theme.textTheme.dark.bodyText1,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );

                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Text(
                          "Deine Sessions",
                          style: _theme.textTheme.dark.headline6,
                        ),
                        Expanded(child: Container()),
                        _SessionInvitesButton(),
                        SizedBox(
                          width: 8,
                        ),
                        _CreateSessionButton()
                      ],
                    ),
                  ),
                );
              }),
        ),
        Consumer<UserManager>(
            builder: (context, um, child) => SliverPadding(
                  padding: const EdgeInsets.only(bottom: 12),
                  sliver: CertifiedSessionsList(_certifiedSessionsStream),
                )),
        SessionsFeed()
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _CreateSessionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BaseTheme _bTheme = ThemeManager.of(context).colors;
    return CustomOpenContainer(
      openBuilder: (context, close, scrollController) =>
          CreateSessionPage(scrollController),
      closedBuilder: (context, open) => InkWell(
        onTap: open,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.add,
            color: _bTheme.textOnContrast,
            size: 24,
          ),
        ),
      ),
      closedShape: CircleBorder(),
      closedElevation: 0,
      closedColor: _bTheme.contrast,
    );
  }
}

class _SessionInvitesButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BaseTheme _bTheme = ThemeManager.of(context).colors;
    return Consumer<UserManager>(
      builder: (context, um, child) => StreamBuilder<List<SessionInvite>>(
          stream: DatabaseService.getSessionInvites(um.uid),
          builder: (context, snapshot) {
            List<SessionInvite> invites = snapshot.data ?? [];

            if (invites.isEmpty) return Container();

            return Stack(
              overflow: Overflow.visible,
              alignment: Alignment.topRight,
              children: [
                CustomOpenContainer(
                  openBuilder: (context, close, scrollController) =>
                      SessionInvitesPage(
                    scrollController: scrollController,
                    invites: invites,
                  ),
                  closedBuilder: (context, open) => InkWell(
                    onTap: open,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.announcement,
                        color: _bTheme.textOnContrast,
                        size: 24,
                      ),
                    ),
                  ),
                  closedShape: CircleBorder(),
                  closedElevation: 0,
                  closedColor: _bTheme.contrast,
                ),
                Positioned(
                  top: -6,
                  right: -6,
                  child: Material(
                    color: Colors.red,
                    shape: CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Center(
                          child: Text(
                        invites.length.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      )),
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }
}
