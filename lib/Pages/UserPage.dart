import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/Components/CampaignHeader.dart';
import 'package:one_d_m/Components/CustomOpenContainer.dart';
import 'package:one_d_m/Components/DonationWidget.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/CertifiedSessionsList.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Donation.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/Numeral.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:one_d_m/Pages/EditProfile.dart';
import 'package:one_d_m/Pages/FollowersListPage.dart';
import 'package:one_d_m/Pages/UsersDonationsPage.dart';
import 'package:provider/provider.dart';

class UserPage extends StatefulWidget {
  User user;
  ScrollController scrollController;

  UserPage(this.user, {this.scrollController});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> with TickerProviderStateMixin {
  bool _followed = false;
  bool _isOwnPage = false;

  ThemeData _theme;
  UserManager um;
  MediaQueryData mq;

  ScrollController _scrollController;
  AnimationController _controller;
  AnimationController _transitionController;

  List<Campaign> campaigns;

  double _staticHeight;
  static final double _staticHeaderTop = 76;

  Stream _donationStream;
  Stream<List<String>> _followingStream;
  List<String> _followers = [];

  double _headerHeight, _headerTop = _staticHeaderTop, _scrollOffset = 0.0;

  User user;

  List<Session> mySessions = [];

  @override
  void initState() {
    super.initState();

    user = widget.user;

    DatabaseService.getCertifiedSessions().listen((event) {
      mySessions.clear();
      event.forEach((element) {
        DatabaseService.userIsInSession(user.id, element.id).listen((isExist) {
          if (isExist) {
            mySessions.add(element);
          }
          setState(() {});
        });
      });
    });

    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    _transitionController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..forward();

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset;
          _controller.value =
              Helper.mapValue(_scrollOffset, 0, _headerHeight - 76, 0, 1);
        });
      });

    _donationStream = DatabaseService.getDonationsFromUserLimit(widget.user.id);

    ///add exisiting followers
    DatabaseService.getFollowingUsersStream(widget.user.id, limit: 5)
        .listen((users) {
      _followers.clear();
      users.forEach((element) {
        DatabaseService.userExist(element).listen((isExist) {
          if (isExist) {
            _followers.add(element);
          }
          setState(() {});
        });
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _transitionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    um = Provider.of<UserManager>(context);
    _isOwnPage = widget.user.id == um.uid;
    mq = MediaQuery.of(context);
    _staticHeight = mq.size.height * .55;
    _headerHeight = _staticHeight + mq.padding.top;
    _headerTop = _staticHeaderTop + mq.padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<UserManager>(
        builder: (context, um, child) => StreamBuilder<User>(
            initialData: user,
            stream: DatabaseService.getUserStream(widget.user.id),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null)
                user = snapshot.data;
              return CustomScrollView(
                controller: widget.scrollController,
                slivers: <Widget>[
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: UserHeader(user),
                  ),
                  _OtherUsersRecommendations(
                    user: user,
                    followingStream: _followers,
                  ),
                  SliverToBoxAdapter(
                      child: Container(
                    width: double.infinity,
                    height: 0.3,
                    color: Colors.black87.withOpacity(0.4),
                  )),
                  mySessions.isNotEmpty
                      ? _buildCampaignSessions(mySessions)
                      : SliverToBoxAdapter(
                          child: SizedBox.shrink(),
                        ),
                  Consumer<UserManager>(builder: (context, um, child) {
                    return StreamBuilder<List<Campaign>>(
                        stream: DatabaseService.getSubscribedCampaignsStream(
                            um.uid),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData)
                            return SliverToBoxAdapter(
                              child: Center(
                                  child: Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 20,
                                  ),
                                  CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation(
                                          ColorTheme.blue)),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text("Laden...")
                                ],
                              )),
                            );

                          campaigns = snapshot.data;

                          if (campaigns.isEmpty)
                            return SliverToBoxAdapter(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  SizedBox(
                                    height: 25,
                                  ),
                                  SvgPicture.asset(
                                    "assets/images/no-news.svg",
                                    height: 200,
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                      "${um.uid == user.id ? "Du" : "${user.name ?? "Gelöschter Account"}"} ${um.uid == user.id ? "hast" : "hat"} noch keine Projekte abonniert!"),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            );

                          return SliverList(
                            delegate:
                                SliverChildListDelegate(_generateChildren()),
                          );
                        });
                  }),
                ],
              );
            }),
      ),
    );
  }

  Widget _buildCampaignSessions(List<Session> sessions) => SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const YMargin(8),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text("Sessions",
                  style: Theme.of(context).textTheme.headline6.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
            ),
            const YMargin(8),
            Container(
              height: 116,
              child: ListView.separated(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (context, index) => SizedBox(
                        width: 8,
                      ),
                  itemBuilder: (context, index) => Padding(
                        padding: EdgeInsets.only(
                            left: index == 0 ? 12.0 : 0.0,
                            right: index == sessions.length - 1 ? 12.0 : 0.0),
                        child: CertifiedSessionView(sessions[index]),
                      ),
                  itemCount: sessions.length),
            ),
          ],
        ),
      );

  List<Widget> _generateDonations(List<Donation> donations) {
    return donations
        .map((d) => DonationWidget(
              d,
              withUsername: false,
            ))
        .toList();
  }

  List<Widget> _generateChildren() {
    List<Widget> list = [];

    list.add(Padding(
      padding: const EdgeInsets.only(left: 10.0, bottom: 10, top: 20),
      child: Text("Unterstützte Projekte (${campaigns.length})",
          style: Theme.of(context).textTheme.headline6.copyWith(
                fontWeight: FontWeight.w600,
              )),
    ));

    for (Campaign c in campaigns) {
      list.add(CampaignHeader(
        campaign: c,
      ));
    }

    list.add(SizedBox(height: mq.size.height * .5));

    return list;
  }
}

class _OtherUsersRecommendations extends StatefulWidget {
  final List<String> followingStream;
  final User user;

  _OtherUsersRecommendations({Key key, this.followingStream, this.user})
      : super(key: key);

  @override
  __OtherUsersRecommendationsState createState() =>
      __OtherUsersRecommendationsState();
}

class __OtherUsersRecommendationsState
    extends State<_OtherUsersRecommendations> {
  ThemeManager _theme;
  bool _show = true;

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);

    return _show
        ? widget.followingStream.isEmpty
            ? SliverToBoxAdapter()
            : SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  height: 180,
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const YMargin(12),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Helper.hexToColor('#2e313f'),
                            ),
                            children: <TextSpan>[
                              TextSpan(text: 'Users '),
                              TextSpan(
                                  text: widget.user.name,
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold)),
                              TextSpan(text: ' follows:'),
                            ],
                          ),
                        ),
                      ),
                      const YMargin(4),
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) => Padding(
                            padding: EdgeInsets.only(
                                left: index == 0 ? 12 : 0,
                                right:
                                    index == widget.followingStream.length - 1
                                        ? 12
                                        : 0),
                            child: _RecommendationUser(
                                widget.followingStream[index]),
                          ),
                          itemCount: widget.followingStream.length,
                        ),
                      ),
                    ],
                  ),
                ),
              )
        : SliverToBoxAdapter();
  }
}

class _RecommendationUser extends StatelessWidget {
  final String uid;

  const _RecommendationUser(this.uid);

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return FutureBuilder<User>(
      future: DatabaseService.getUser(uid),
      builder: (context, snapshot) {
        User user = snapshot.data;
        bool deleted = snapshot.hasData && snapshot.data?.name == null;

        return Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 3,
                child: CustomOpenContainer(
                  openBuilder: (context, close, scrollController) => UserPage(
                    user,
                    scrollController: scrollController,
                  ),
                  closedElevation: 0,
                  closedColor: Colors.white,
                  closedShape: CircleBorder(),
                  closedBuilder: (context, open) => InkWell(
                    onTap: open,
                    child: Container(
                        height: 75,
                        width: 75,
                        child: CachedNetworkImage(
                          imageUrl: user?.imgUrl ?? '',
                          imageBuilder: (_, imgProvider) => Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(width: 0.5, color: Colors.black),
                              image: DecorationImage(
                                image: imgProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            decoration: BoxDecoration(
                              color: ThemeManager.of(context).colors.contrast,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(width: 0.5, color: Colors.black),
                            ),
                            child: Center(
                                child: Icon(
                              Icons.person,
                              color: ThemeManager.of(context).colors.dark,
                            )),
                          ),
                          placeholder: (_, __) => Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(width: 0.5, color: Colors.black),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        )),
                  ),
                ),
              ),
              SizedBox(
                height: 3,
              ),
              Expanded(
                child: AutoSizeText(
                    deleted ? "Gelöschter Nutzer" : user?.name ?? "Laden...",
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.headline6.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: Helper.hexToColor('#2e313f'))),
              ),
            ],
          ),
        );
      },
    );
  }
}

class UserHeader extends SliverPersistentHeaderDelegate {
  final int index = 0;
  final User user;
  ThemeManager _theme;
  double _minExtend = 80.0;

  UserHeader(this.user);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    _theme = ThemeManager.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      _minExtend = MediaQuery.of(context).padding.top + 56.0;
      final double percentage =
          (constraints.maxHeight - minExtent) / (maxExtent - minExtent);

      return Container(
        height: constraints.maxHeight,
        child: Material(
          color: _theme.colors.dark,
          elevation: 1,
          child: SafeArea(
            bottom: false,
            child: Wrap(
              alignment: WrapAlignment.center,
              runSpacing: 0,
              children: <Widget>[
                AppBar(
                  leading: IconButton(
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 48,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  brightness: Brightness.dark,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: IconThemeData(color: _theme.colors.textOnDark),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildUserImage(context),
                    const XMargin(15),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${user?.name ?? "Gelöschter Account"}",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700),
                        ),
                        const YMargin(10),
                        _followButton()
                      ],
                    )
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      _followersCollumn(
                          text: "Abonnenten",
                          stream:
                              DatabaseService.getFollowedUsersStream(user.id)),
                      Material(
                        borderRadius: BorderRadius.circular(5),
                        clipBehavior: Clip.antiAlias,
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: (user?.donatedAmount == null
                                      ? 0
                                      : user.donatedAmount) >
                                  0
                              ? () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (c) =>
                                              UsersDonationsPage(user)));
                                }
                              : null,
                          child: _textNumberColumn(
                              text: "Unterstützt",
                              number:
                                  "${Numeral(user?.donatedAmount).value()} DV"),
                        ),
                      ),
                      _followersCollumn(
                          text: "Abonniert",
                          stream:
                              DatabaseService.getFollowingUsersStream(user.id)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildUserImage(BuildContext context) => CachedNetworkImage(
        imageUrl: user.imgUrl ?? '',
        imageBuilder: (context, imageProvider) => Container(
          height: 88.0,
          width: 88.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          height: 88,
          width: 88,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            color: ThemeManager.of(context).colors.contrast,
          ),
          child: Center(
              child: Icon(
            Icons.person,
            color: ThemeManager.of(context).colors.dark,
          )),
        ),
        placeholder: (_, __) => Container(
          height: 88,
          width: 88,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate _) => true;

  @override
  double get maxExtent => 280.0;

  @override
  double get minExtent => _minExtend;

  Widget _followButton() {
    return user.name == null
        ? Container()
        : Consumer<UserManager>(builder: (context, um, child) {
            if (um.uid == user.id)
              return OfflineBuilder(
                  child: Container(),
                  connectivityBuilder: (context, connection, child) {
                    if (connection == ConnectivityResult.none)
                      return FloatingActionButton(
                        onPressed: () {
                          Helper.showConnectionSnackBar(context);
                        },
                        child: Icon(
                          Icons.signal_wifi_off,
                          color: ColorTheme.orange,
                        ),
                        backgroundColor: ColorTheme.whiteBlue,
                      );
                    return CustomOpenContainer(
                      openBuilder: (context, close, controller) =>
                          EditProfile(),
                      closedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      closedBuilder: (context, open) => Container(
                        width: 100,
                        height: 41,
                        color: ThemeManager.of(context).colors.contrast,
                        child: InkWell(
                          onTap: open,
                          child: Center(
                            child: Text(
                              'Edit',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: ThemeManager.of(context).colors.dark),
                            ),
                          ),
                        ),
                      ),
                    );
                  });

            return StreamBuilder<bool>(
                initialData: false,
                stream: DatabaseService.getFollowStream(um.uid, user.id),
                builder: (context, snapshot) {
                  bool _followed = snapshot.data;

                  return Container(
                      width: 100,
                      height: 41,
                      decoration: BoxDecoration(
                          color: ThemeManager.of(context).colors.contrast,
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      child: InkWell(
                        onTap: () async {
                          await _toggleFollow(um.uid, _followed);
                        },
                        child: Center(
                          child: Text(
                            _followed ? 'Entfolgen' : 'Folgen',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: ThemeManager.of(context).colors.dark),
                          ),
                        ),
                      ));
                });
          });
  }

  Future<void> _toggleFollow(String uid, bool followed) async {
    if (followed) {
      await DatabaseService.deleteFollow(uid, user.id);
    } else {
      await DatabaseService.createFollow(uid, user.id);
    }
  }

  Widget _followersCollumn(
      {String text, Stream stream, CrossAxisAlignment alignment}) {
    return StreamBuilder<List<String>>(
        stream: stream,
        builder: (context, snapshot) {
          return Material(
            color: Colors.transparent,
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(5),
            child: InkWell(
              onTap: snapshot.hasData && snapshot.data.isNotEmpty
                  ? () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) => FollowersListPage(
                                    title: text,
                                    userIDs: snapshot.data,
                                  )));
                    }
                  : null,
              child: _textNumberColumn(
                  number:
                      snapshot.hasData ? snapshot.data.length.toString() : "0",
                  text: text,
                  alignment: alignment),
            ),
          );
        });
  }

  Widget _textNumberColumn(
      {String text,
      String number,
      CrossAxisAlignment alignment = CrossAxisAlignment.center}) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          AutoSizeText(
            number.toString(),
            maxLines: 1,
            style: _theme.textTheme.textOnDark.headline6
                .copyWith(fontWeight: FontWeight.w600, fontSize: 24),
          ),
          const YMargin(10),
          Text(
            text,
            style: _theme.materialTheme.accentTextTheme.bodyText1.copyWith(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
          )
        ],
      ),
    );
  }
}
