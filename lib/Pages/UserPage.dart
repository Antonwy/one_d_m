import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/Components/CampaignHeader.dart';
import 'package:one_d_m/Components/CustomOpenContainer.dart';
import 'package:one_d_m/Components/DonationWidget.dart';
import 'package:one_d_m/Components/FollowButton.dart';
import 'package:one_d_m/Components/UserButton.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Donation.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/Numeral.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
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

  double _headerHeight, _headerTop = _staticHeaderTop, _scrollOffset = 0.0;

  User user;

  @override
  void initState() {
    super.initState();

    user = widget.user;

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
    _followingStream =
        DatabaseService.getFollowingUsersStream(widget.user.id, limit: 5);
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
                    followingStream: _followingStream,
                  ),
                  StreamBuilder<List<Donation>>(
                      stream: _donationStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return SliverToBoxAdapter();
                        if (snapshot.data.isEmpty) return SliverToBoxAdapter();
                        return SliverPadding(
                          padding: const EdgeInsets.fromLTRB(10, 18, 10, 0),
                          sliver: SliverToBoxAdapter(
                            child: Text(
                              "Letzte Unterstützungen",
                              style: _theme.textTheme.headline6,
                            ),
                          ),
                        );
                      }),
                  StreamBuilder<List<Donation>>(
                      stream: _donationStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return SliverToBoxAdapter();
                        if (snapshot.data.isEmpty) return SliverToBoxAdapter();
                        return SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          sliver: SliverList(
                              delegate: SliverChildListDelegate(
                                  _generateDonations(snapshot.data))),
                        );
                      }),
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
      child: Text(
        "Unterstützte Projekte (${campaigns.length})",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      ),
    ));

    for (Campaign c in campaigns) {
      list.add(CampaignHeader(c));
    }

    list.add(SizedBox(height: mq.size.height * .5));

    return list;
  }
}

class _OtherUsersRecommendations extends StatefulWidget {
  final Stream<List<String>> followingStream;
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
        ? StreamBuilder<List<String>>(
            stream: widget.followingStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return SliverToBoxAdapter();
              if (snapshot.data.isEmpty) return SliverToBoxAdapter();
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(10, 18, 10, 0),
                sliver: SliverToBoxAdapter(
                  child: Material(
                    elevation: 1,
                    borderRadius: BorderRadius.circular(6),
                    color: _theme.colors.contrast,
                    clipBehavior: Clip.antiAlias,
                    child: Theme(
                      data: ThemeData(
                          accentColor: _theme.colors.textOnContrast,
                          unselectedWidgetColor:
                              _theme.colors.textOnContrast.withOpacity(.8)),
                      child: ExpansionTile(
                          initiallyExpanded: true,
                          title: RichText(
                            text: TextSpan(
                                style:
                                    _theme.textTheme.textOnContrast.bodyText2,
                                children: [
                                  TextSpan(text: "Personen denen "),
                                  TextSpan(
                                      text: "${widget.user.name} ",
                                      style: _theme
                                          .textTheme.textOnContrast.bodyText1
                                          .copyWith(
                                              fontWeight: FontWeight.bold)),
                                  TextSpan(text: "folgt:"),
                                ]),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                height: 125,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) => Padding(
                                    padding: EdgeInsets.only(
                                        left: index == 0 ? 12 : 0,
                                        right:
                                            index == snapshot.data?.length - 1
                                                ? 12
                                                : 0),
                                    child: _RecommendationUser(
                                        snapshot.data[index]),
                                  ),
                                  itemCount: snapshot.data?.length,
                                ),
                              ),
                            ),
                          ]),
                    ),
                  ),
                ),
              );
            })
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

        return Container(
          height: 125,
          width: 108,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: CustomOpenContainer(
              openBuilder: (context, close, scrollController) => UserPage(
                user,
                scrollController: scrollController,
              ),
              closedElevation: 1,
              closedColor: Colors.white,
              closedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              closedBuilder: (context, open) => Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Expanded(
                        child: RoundedAvatar(
                      user?.imgUrl,
                      loading: !snapshot.hasData,
                      color: _theme.colors.dark,
                      iconColor: _theme.colors.contrast,
                    )),
                    SizedBox(
                      height: 12,
                    ),
                    Expanded(
                      child: Container(
                        width: 76,
                        height: double.infinity,
                        child: AutoSizeText(
                            deleted
                                ? "Gelöschter Nutzer"
                                : user?.name ?? "Laden...",
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: _theme.textTheme.dark.headline6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
              runSpacing: 20,
              spacing: 20,
              children: <Widget>[
                AppBar(
                  brightness: Brightness.dark,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: IconThemeData(color: _theme.colors.textOnDark),
                  title: Text(
                    "${user?.name ?? "Gelöschter Account"}",
                    style: TextStyle(color: _theme.colors.textOnDark),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        width: 75,
                        height: 75,
                        child: RoundedAvatar(
                          user.imgUrl,
                          color: _theme.colors.contrast,
                          iconColor: _theme.colors.textOnContrast,
                        )),
                    SizedBox(
                      width: 20,
                    ),
                    _followButton()
                  ],
                ),
                Container(
                  width: constraints.maxWidth * .9,
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
                                  "${Numeral(user?.donatedAmount).value()} DC"),
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
                      closedShape: CircleBorder(),
                      closedBuilder: (context, open) => Container(
                        width: 56,
                        height: 56,
                        child: InkWell(
                          onTap: open,
                          child: Icon(
                            Icons.edit,
                            color: ColorTheme.blue,
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

                  return Center(
                      child: FollowButton(
                    followed: _followed,
                    onPressed: () async {
                      await _toggleFollow(um.uid, _followed);
                    },
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
    return Container(
      height: 57,
      child: StreamBuilder<List<String>>(
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
                    number: snapshot.hasData
                        ? snapshot.data.length.toString()
                        : "0",
                    text: text,
                    alignment: alignment),
              ),
            );
          }),
    );
  }

  Widget _textNumberColumn(
      {String text,
      String number,
      CrossAxisAlignment alignment = CrossAxisAlignment.center}) {
    return Container(
      width: 100,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            AutoSizeText(
              number.toString(),
              maxLines: 1,
              style: _theme.textTheme.textOnDark.headline6,
            ),
            Text(
              text,
              style: _theme.materialTheme.accentTextTheme.bodyText1
                  .copyWith(color: _theme.colors.textOnDark.withOpacity(.5)),
            )
          ],
        ),
      ),
    );
  }
}
