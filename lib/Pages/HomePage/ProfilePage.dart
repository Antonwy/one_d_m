import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:line_icons/line_icons.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Components/BottomDialog.dart';
import 'package:one_d_m/Components/CustomOpenContainer.dart';
import 'package:one_d_m/Components/InfoFeed.dart';
import 'package:one_d_m/Components/RoundButtonHomePage.dart';
import 'package:one_d_m/Components/SettingsDialog.dart';
import 'package:one_d_m/Components/post_item_widget.dart';
import 'package:one_d_m/Helper/CertifiedSessionsList.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/Numeral.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:one_d_m/Pages/HomePage/HomePage.dart';
import 'package:one_d_m/Pages/RewardVideoPage.dart';
import 'package:one_d_m/Pages/UserPage.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback onExploreTapped;

  const ProfilePage({Key key, this.onExploreTapped, }) : super(key: key);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  GlobalKey<_ProfilePageState> _myKey = GlobalKey();

  ThemeManager _theme;
  Stream<List<BaseSession>> _sessionStream;
  Stream<List<BaseSession>> _certifiedSessionsStream;
  List<Session> mySessions = [];

  @override
  void initState() {
    String uid = Provider.of<UserManager>(context, listen: false).uid;
    _sessionStream = DatabaseService.getSessionsFromUser(uid);
    _certifiedSessionsStream =
        DatabaseService.getCertifiedSessionsFromUser(uid);

    ///listen events for user followed sessions
    DatabaseService.getCertifiedSessions().listen((event) {
      mySessions.clear();
      event.forEach((element) {
        DatabaseService.userIsInSession(uid, element.id).listen((isExist) {
          if (isExist) {
            mySessions.add(element);
          }
          setState(() {});
        });
      });
    });
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

        ///build the sessions that follow by user
        mySessions.isNotEmpty
            ? _buildMySessions(mySessions)
            : _buildEmptySession(),
        // SessionsFeed(),
        // _buildPostFeed(),

        _buildPostFeed(),
        const SliverToBoxAdapter(
          child: const SizedBox(
            height: 120,
          ),
        )
        // _buildPostFeed(),
      ],
    );
  }

  Widget _buildPostFeed() => StreamBuilder<List<News>>(
      stream: DatabaseService.getSessionPosts(),
      builder: (context, AsyncSnapshot<List<News>> snapshot) {
        if (!snapshot.hasData)
          return SliverToBoxAdapter(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        List<News> news = snapshot.data;

        List<String> sessionsWithPost = [];
        List<String> mySessionPosts = [];
        List<PostItem> postItem = [];

        news.forEach((element) {
          sessionsWithPost.add(element.sessionId);
        });
        //filter user following session posts
        for (Session s in mySessions) {
          if (sessionsWithPost.contains(s.id)) {
            mySessionPosts.add(s.id);
          }
        }

        ///remove duplicating ids
        mySessionPosts.toSet().toList().forEach((element) {
          postItem.add(HeadingItem(DatabaseService.getSessionFuture(element)));
          postItem.add(
              PostContentItem(DatabaseService.getPostBySessionId(element)));
        });
        if (postItem.isNotEmpty) {
          return SliverList(
              delegate: SliverChildListDelegate(_buildPostWidgets(postItem)));
        } else {
          return SliverToBoxAdapter(child: SizedBox.shrink());
        }
      });

  List<Widget> _buildPostWidgets(List<PostItem> post) {
    List<Widget> widgets = [];
    widgets.add(_buildNewsTitleWidget());
    for (PostItem p in post) {
      widgets.add(Column(
        children: [p.buildHeading(context), p.buildPosts(context)],
      ));
    }
    return widgets;
  }

  Widget _buildEmptySession() => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              SvgPicture.asset(
                "assets/images/no-donations.svg",
                height: 70,
                width: 70,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Du bist momentan kein Mitglied einer Session",
                style: _theme.textTheme.dark.bodyText1,
                textAlign: TextAlign.center,
              ),
              const YMargin(20),
              FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.black)),
                onPressed: widget.onExploreTapped,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Entdecke Sessions',
                    style: Theme.of(context).textTheme.headline6.copyWith(
                        fontWeight: FontWeight.bold, fontSize: 18.0),
                  ),
                ),
              ),

            ],
          ),
        ),
      );

  Widget _buildMySessions(List<BaseSession> sessions) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(
              left: 12.0, top: 12.0, bottom: 12.0, right: 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Deine Sessions",
                style: _theme.textTheme.dark.headline6.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Helper.hexToColor('#575757')),
              ),
              const SizedBox(
                height: 12.0,
              ),
              Container(
                height: 116,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: CertifiedSessionView(sessions[index]),
                      );
                    },
                    itemCount: sessions.length),
              ),
            ],
          ),
        ),
      );

  Widget _buildNewsTitleWidget() => Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          "News",
          style: _theme.textTheme.dark.headline6.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Helper.hexToColor('#575757')),
        ),
      );

  @override
  bool get wantKeepAlive => true;
}
