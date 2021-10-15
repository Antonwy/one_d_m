import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/components/campaigns/campaign_header.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/components/sessions/session_view.dart';
import 'package:one_d_m/components/users/user_header.dart';
import 'package:one_d_m/components/users/vertical_user_button.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:one_d_m/helper/helper.dart';
import 'package:one_d_m/models/campaign_models/base_campaign.dart';
import 'package:one_d_m/models/session_models/base_session.dart';
import 'package:one_d_m/models/user.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:one_d_m/provider/user_page_manager.dart';
import 'package:provider/provider.dart';

class UserPage extends StatefulWidget {
  User user;
  ScrollController? scrollController;

  UserPage(this.user, {this.scrollController});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> with TickerProviderStateMixin {
  late UserManager um;
  late MediaQueryData mq;

  late ScrollController _scrollController;
  late AnimationController _controller;

  late double _staticHeight;
  static final double _staticHeaderTop = 76;

  double? _headerHeight, _scrollOffset = 0.0;

  User? user;

  Future<List<String>>? mySessions;

  @override
  void initState() {
    super.initState();

    user = widget.user;

    context.read<FirebaseAnalytics>().setCurrentScreen(screenName: "User Page");

    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset;
          _controller.value =
              Helper.mapValue(_scrollOffset, 0, _headerHeight! - 76, 0, 1);
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    um = Provider.of<UserManager>(context);
    mq = MediaQuery.of(context);
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _staticHeight = mq.size.height * .55;
    _headerHeight = _staticHeight + mq.padding.top;

    SystemChrome.setSystemUIOverlayStyle(context.systemOverlayStyle);

    return Scaffold(
        body: ChangeNotifierProvider<UserPageManager>(
            create: (context) => UserPageManager(widget.user, um.uid),
            builder: (context, snapshot) {
              return Consumer<UserManager>(
                  builder: (context, um, child) => CustomScrollView(
                        controller: widget.scrollController,
                        slivers: <Widget>[
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: UserHeader(),
                          ),
                          _OtherUsersRecommendations(),
                          Consumer<UserPageManager>(
                              builder: (context, upm, child) {
                            return SliverAnimatedOpacity(
                              duration: Duration(milliseconds: 250),
                              opacity: upm.loadingMoreInfo ? 0 : 1,
                              sliver: (!upm.loadingMoreInfo)
                                  ? _buildCampaignSessions(
                                      upm.userAccount!.subscribedSessions)
                                  : SliverToBoxAdapter(
                                      child: SizedBox.shrink(),
                                    ),
                            );
                          }),
                          Consumer<UserPageManager>(
                            builder: (context, upm, child) =>
                                SliverAnimatedOpacity(
                              duration: Duration(milliseconds: 250),
                              opacity: upm.loadingMoreInfo ? 0 : 1,
                              sliver: child,
                            ),
                            child: Consumer<UserPageManager>(
                                builder: (context, upm, child) {
                              if (upm.loadingMoreInfo)
                                return SliverToBoxAdapter();

                              if (upm.userAccount!.subscribedCampaigns.isEmpty)
                                return SliverToBoxAdapter(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 32,
                                      ),
                                      SvgPicture.asset(
                                        "assets/images/no-news.svg",
                                        height: 120,
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12.0),
                                        child: Text(
                                          buildNotFoundString(upm),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  ),
                                );

                              return SliverList(
                                delegate: SliverChildListDelegate(
                                    _generateChildren(
                                        upm.userAccount!.subscribedCampaigns)),
                              );
                            }),
                          ),
                        ],
                      ));
            }));
  }

  String buildNotFoundString(UserPageManager upm) {
    String? name = upm.uid == upm.user.id ? 'Du' : upm.user.name;
    String verb = upm.uid == upm.user.id ? "hast" : "hat";
    String projectSession = upm.userAccount!.subscribedSessions.isEmpty
        ? 'Projekte und Sessions'
        : "Projekte";
    return "$name $verb noch keine $projectSession abonniert!";
  }

  Widget _buildCampaignSessions(List<BaseSession> sessions) =>
      SliverToBoxAdapter(
        child: sessions.length == 0
            ? null
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const YMargin(8),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, top: 12),
                    child: Text("Sessions",
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                              fontWeight: FontWeight.w600,
                            )),
                  ),
                  const YMargin(8),
                  Container(
                    height: 180,
                    child: ListView.separated(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        separatorBuilder: (context, index) => SizedBox(
                              width: 8,
                            ),
                        itemBuilder: (context, index) => Padding(
                              padding: EdgeInsets.only(
                                  left: index == 0 ? 12.0 : 0.0,
                                  right: index == sessions.length - 1
                                      ? 12.0
                                      : 0.0),
                              child: SessionView(sessions[index]),
                            ),
                        itemCount: sessions.length),
                  ),
                ],
              ),
      );

  List<Widget> _generateChildren(List<BaseCampaign> campaigns) {
    List<Widget> list = [];

    list.add(Padding(
      padding: const EdgeInsets.only(left: 10.0, bottom: 10, top: 20),
      child: Text("Unterstützte Projekte (${campaigns.length})",
          style: Theme.of(context).textTheme.headline6!.copyWith(
                fontWeight: FontWeight.w600,
              )),
    ));

    for (BaseCampaign c in campaigns) {
      list.add(CampaignHeader(
        campaign: c,
      ));
    }

    list.add(YMargin(24));
    return list;
  }
}

class _OtherUsersRecommendations extends StatefulWidget {
  @override
  __OtherUsersRecommendationsState createState() =>
      __OtherUsersRecommendationsState();
}

class __OtherUsersRecommendationsState
    extends State<_OtherUsersRecommendations> {
  late ThemeData _theme;

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);

    return Consumer<UserPageManager>(builder: (context, upm, child) {
      List<User> followers = upm.userAccount?.followingUsers ?? [];

      return SliverToBoxAdapter(
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 250),
          opacity: upm.loadingMoreInfo ? 0 : 1,
          child: upm.loadingMoreInfo || followers.isEmpty
              ? Container(height: 0)
              : Padding(
                  padding: const EdgeInsets.fromLTRB(10, 18, 10, 0),
                  child: Material(
                    elevation: 0,
                    borderRadius: BorderRadius.circular(6),
                    clipBehavior: Clip.antiAlias,
                    child: ExpansionTile(
                        maintainState: true,
                        initiallyExpanded: true,
                        iconColor:
                            _theme.darkMode ? Colors.white : Colors.black,
                        collapsedIconColor:
                            _theme.darkMode ? Colors.white : Colors.black,
                        title: RichText(
                          text: TextSpan(
                              style: _theme.textTheme.bodyText2,
                              children: [
                                TextSpan(text: "Personen denen "),
                                TextSpan(
                                    text: "${upm.user.name} ",
                                    style: _theme.textTheme.bodyText1!
                                        .copyWith(fontWeight: FontWeight.bold)),
                                TextSpan(text: "folgt:"),
                              ]),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              height: 140,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                separatorBuilder: (context, index) =>
                                    XMargin(6),
                                itemBuilder: (context, index) => Padding(
                                  padding: EdgeInsets.only(
                                      left: index == 0 ? 12 : 0,
                                      right:
                                          index == (followers.length ?? 1) - 1
                                              ? 12
                                              : 0,
                                      bottom: 4),
                                  child: VerticalUserButton(followers[index]),
                                ),
                                itemCount: followers.length,
                              ),
                            ),
                          ),
                        ]),
                  ),
                ),
        ),
      );
    });
  }
}
