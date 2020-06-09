import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:one_d_m/Components/BottomDialog.dart';
import 'package:one_d_m/Components/DonationDialogWidget.dart';
import 'package:one_d_m/Components/DonationWidget.dart';
import 'package:one_d_m/Components/FollowButton.dart';
import 'package:one_d_m/Components/NewsPost.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Donation.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/Numeral.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/CreateNewsPage.dart';
import 'package:provider/provider.dart';

class NewCampaignPage extends StatefulWidget {
  Campaign campaign;
  ScrollController scrollController;

  NewCampaignPage(this.campaign, {Key key, this.scrollController})
      : super(key: key);

  @override
  _NewCampaignPageState createState() => _NewCampaignPageState();
}

class _NewCampaignPageState extends State<NewCampaignPage>
    with SingleTickerProviderStateMixin {
  TextTheme _textTheme;
  bool _subscribed = false;
  Campaign campaign;
  MediaQueryData _mq;
  ScrollController _scrollController;
  ValueNotifier _scrollOffset;

  Stream<Campaign> _campaignStream;
  Stream<List<Donation>> _donationStream;

  bool _isAuthorOfCampaign = false;

  AnimationController _transitionController;

  @override
  void initState() {
    _scrollController = widget.scrollController ?? ScrollController();

    _scrollOffset = ValueNotifier(0);

    _scrollController.addListener(() {
      _scrollOffset.value = _scrollController.offset;
    });

    _transitionController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));

    _transitionController.forward();

    _campaignStream = DatabaseService.getCampaignStream(widget.campaign.id);
    _donationStream =
        DatabaseService.getDonationFromCampaignStream(widget.campaign.id);

    super.initState();
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;
    _mq = MediaQuery.of(context);
    return Scaffold(
        floatingActionButton: OfflineBuilder(
            child: Container(),
            connectivityBuilder: (context, connection, child) {
              bool activated = connection != ConnectivityResult.none;
              return Consumer<UserManager>(builder: (context, um, child) {
                return StreamBuilder<Campaign>(
                    initialData: widget.campaign,
                    stream: _campaignStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data.authorId != null) {
                        _isAuthorOfCampaign = snapshot.data.authorId == um.uid;
                      }

                      return ScaleTransition(
                        scale: Tween<double>(begin: .8, end: 1.0).animate(
                            CurvedAnimation(
                                parent: _transitionController,
                                curve: Interval(.2, .8,
                                    curve: Curves.fastLinearToSlowEaseIn))),
                        child: SlideTransition(
                          position: Tween<Offset>(
                                  begin: Offset(0, 1.0), end: Offset.zero)
                              .animate(CurvedAnimation(
                                  parent: _transitionController,
                                  curve: Interval(.2, .8,
                                      curve: Curves.fastLinearToSlowEaseIn))),
                          child: FadeTransition(
                            opacity: CurvedAnimation(
                                parent: _transitionController,
                                curve: Interval(.2, .8,
                                    curve: Curves.fastLinearToSlowEaseIn)),
                            child: FloatingActionButton.extended(
                                backgroundColor:
                                    activated ? ColorTheme.blue : Colors.grey,
                                label: _isAuthorOfCampaign
                                    ? Text("Post erstellen")
                                    : Text("Spenden"),
                                onPressed: activated
                                    ? _isAuthorOfCampaign
                                        ? () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (c) =>
                                                        CreateNewsPage(
                                                            campaign)));
                                          }
                                        : () {
                                            BottomDialog bd =
                                                BottomDialog(context);
                                            bd.show(DonationDialogWidget(
                                              campaign: snapshot.data,
                                              user: um.user,
                                              context: context,
                                              close: bd.close,
                                            ));
                                          }
                                    : () {
                                        Helper.showConnectionSnackBar(context);
                                      }),
                          ),
                        ),
                      );
                    });
              });
            }),
        body: StreamBuilder<Campaign>(
            initialData: widget.campaign,
            stream: _campaignStream,
            builder: (context, snapshot) {
              campaign = snapshot.data;

              return Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: _mq.size.height * .3 + 30,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                  widget.campaign.imgUrl))),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ValueListenableBuilder(
                        valueListenable: _scrollOffset,
                        builder: (context, value, child) {
                          return Container(
                              height: (_mq.size.height * .7 + value)
                                  .clamp(0, _mq.size.height),
                              width: double.infinity,
                              child: Material(
                                color: ColorTheme.white,
                                elevation: 20,
                                clipBehavior: Clip.antiAlias,
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(30)),
                              ));
                        }),
                  ),
                  MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          SliverToBoxAdapter(
                            child: SizedBox(
                              height: _mq.size.height * .3,
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14, vertical: 18),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            campaign.name,
                                            style: _textTheme.headline5
                                                .copyWith(
                                                    fontSize: 30,
                                                    fontWeight:
                                                        FontWeight.w500),
                                          ),
                                          Text(
                                            "${campaign?.shortDescription}",
                                            style: _textTheme.caption,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Consumer<UserManager>(
                                        builder: (context, um, child) {
                                      return StreamBuilder<User>(
                                          initialData: um.user,
                                          stream: DatabaseService.getUserStream(
                                              um.uid),
                                          builder: (context, snapshot) {
                                            _subscribed = snapshot
                                                .data?.subscribedCampaignsIds
                                                ?.contains(widget.campaign.id);
                                            um.user.subscribedCampaignsIds =
                                                snapshot.data
                                                    .subscribedCampaignsIds;
                                            return FollowButton(
                                              onPressed: () async =>
                                                  _toggleSubscribed(um.uid),
                                              followed: _subscribed ?? false,
                                            );
                                          });
                                    }),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  height: 100,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      _StatCollumn(
                                          controller: _transitionController,
                                          interval: Interval(.1, .6),
                                          value: campaign.amount,
                                          description: "Donation Credits"),
                                      _StatCollumn(
                                          controller: _transitionController,
                                          interval: Interval(.2, .7),
                                          value: campaign.subscribedCount,
                                          description: "Abonnenten",
                                          isDark: true),
                                    ],
                                  ),
                                ),
                                Consumer<UserManager>(
                                  builder: (context, um, child) => Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      _AmountWidget(
                                        1,
                                        user: um.user,
                                        campaign: campaign,
                                        controller: _transitionController,
                                        interval: Interval(0.2, .7),
                                      ),
                                      _AmountWidget(
                                        2,
                                        user: um.user,
                                        campaign: campaign,
                                        controller: _transitionController,
                                        interval: Interval(0.3, .8),
                                      ),
                                      _AmountWidget(
                                        5,
                                        user: um.user,
                                        campaign: campaign,
                                        controller: _transitionController,
                                        interval: Interval(0.4, .8),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                SlideTransition(
                                  position: Tween<Offset>(
                                          begin: Offset(0.0, 4.0),
                                          end: Offset.zero)
                                      .animate(CurvedAnimation(
                                          parent: _transitionController,
                                          curve: Interval(.1, .7,
                                              curve: Curves
                                                  .fastLinearToSlowEaseIn))),
                                  child: FadeTransition(
                                    opacity: CurvedAnimation(
                                        parent: _transitionController,
                                        curve: Interval(.1, .7,
                                            curve:
                                                Curves.fastLinearToSlowEaseIn)),
                                    child: Text("Beschreibung",
                                        style: _textTheme.headline6),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                SlideTransition(
                                  position: Tween<Offset>(
                                          begin: Offset(0.0, .1),
                                          end: Offset.zero)
                                      .animate(CurvedAnimation(
                                          parent: _transitionController,
                                          curve: Interval(.2, .8,
                                              curve: Curves
                                                  .fastLinearToSlowEaseIn))),
                                  child: FadeTransition(
                                    opacity: CurvedAnimation(
                                        parent: _transitionController,
                                        curve: Interval(.2, .8,
                                            curve:
                                                Curves.fastLinearToSlowEaseIn)),
                                    child: Text(campaign.description ?? "",
                                        style: _textTheme.bodyText2),
                                  ),
                                ),
                                StreamBuilder<List<Donation>>(
                                    stream: _donationStream,
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) return Container();
                                      if (snapshot.data.isEmpty)
                                        return Container();
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Text("Spenden",
                                              style: _textTheme.headline6),
                                        ],
                                      );
                                    }),
                              ]),
                            ),
                          ),
                          StreamBuilder<List<Donation>>(
                              stream: _donationStream,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData)
                                  return SliverToBoxAdapter();
                                return SliverPadding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  sliver: SliverList(
                                    delegate:
                                        SliverChildListDelegate(snapshot.data
                                            .map((d) => DonationWidget(
                                                  d,
                                                  campaignPage: true,
                                                ))
                                            .toList()),
                                  ),
                                );
                              }),
                          StreamBuilder<List<News>>(
                              stream: DatabaseService.getNewsFromCampaignStream(
                                  campaign),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    (snapshot.hasData && snapshot.data.isEmpty))
                                  return SliverToBoxAdapter(
                                    child: SizedBox(
                                      height: 100,
                                    ),
                                  );
                                return SliverPadding(
                                  padding: EdgeInsets.fromLTRB(18, 0, 18, 80),
                                  sliver: SliverList(
                                      delegate: SliverChildListDelegate([
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 18.0),
                                      child: Text(
                                          "Neuigkeiten (${snapshot.data.length})",
                                          style: _textTheme.headline6),
                                    ),
                                    ...snapshot.data
                                        .map((n) =>
                                            NewsPost(n, withCampaign: false))
                                        .toList()
                                  ])),
                                );
                              }),
                        ]),
                  ),
                  Positioned(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: ScaleTransition(
                        scale: CurvedAnimation(
                            parent: _transitionController,
                            curve: Interval(.1, .6,
                                curve: Curves.fastLinearToSlowEaseIn)),
                        child: Material(
                          clipBehavior: Clip.antiAlias,
                          shape: CircleBorder(),
                          elevation: 10,
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: IconButton(
                                icon: Icon(Icons.arrow_downward),
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                          ),
                        ),
                      ),
                    ),
                    top: MediaQuery.of(context).padding.top,
                    left: 0,
                  ),
                  Consumer<UserManager>(
                    builder: (context, um, child) => StreamBuilder<Campaign>(
                        initialData: widget.campaign,
                        stream: _campaignStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData &&
                              snapshot.data.authorId != null &&
                              snapshot.data.authorId != um.uid)
                            return Container();

                          if (!snapshot.hasData ||
                              snapshot.data?.authorId == null ||
                              snapshot.data?.authorId != null)
                            return Container();

                          return Positioned(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Material(
                                clipBehavior: Clip.antiAlias,
                                shape: CircleBorder(),
                                elevation: 10,
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        DatabaseService.deleteCampaign(
                                            campaign);
                                      }),
                                ),
                              ),
                            ),
                            top: MediaQuery.of(context).padding.top,
                            right: 0,
                          );
                        }),
                  ),
                ],
              );
            }));
  }

  Future<void> _toggleSubscribed(String uid) async {
    if (_subscribed)
      await DatabaseService.deleteSubscription(campaign, uid);
    else
      await DatabaseService.createSubscription(campaign, uid);
  }
}

class _StatCollumn extends StatelessWidget {
  final int value;
  final String description;
  final bool isDark;
  final Interval interval;
  final AnimationController controller;

  _StatCollumn(
      {this.value,
      this.description,
      this.isDark = false,
      this.interval,
      this.controller});

  @override
  Widget build(BuildContext context) {
    Interval _interval = Interval(interval.begin, interval.end,
        curve: Curves.fastLinearToSlowEaseIn);
    return Expanded(
      child: SlideTransition(
        position: Tween<Offset>(begin: Offset(0.0, .2), end: Offset.zero)
            .animate(CurvedAnimation(parent: controller, curve: _interval)),
        child: ScaleTransition(
          scale: Tween<double>(begin: .9, end: 1.0)
              .animate(CurvedAnimation(parent: controller, curve: _interval)),
          child: FadeTransition(
            opacity: CurvedAnimation(parent: controller, curve: _interval),
            child: Card(
              elevation: 0,
              color: isDark ? ColorTheme.blue : ColorTheme.orange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "${Numeral(value ?? 0).value()}",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                        color: isDark ? ColorTheme.orange : ColorTheme.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    description,
                    style: TextStyle(
                        color: isDark ? ColorTheme.orange : ColorTheme.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AmountWidget extends StatelessWidget {
  final int amount;
  final User user;
  final Campaign campaign;

  final Interval interval;
  final AnimationController controller;

  _AmountWidget(this.amount,
      {this.user, this.campaign, this.interval, this.controller});

  TextTheme _textTheme;

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;
    Interval _interval = Interval(interval.begin, interval.end,
        curve: Curves.fastLinearToSlowEaseIn);
    return Expanded(
      child: OfflineBuilder(
          child: Container(),
          connectivityBuilder: (context, connection, child) {
            bool activated = connection != ConnectivityResult.none;
            return AnimatedOpacity(
              duration: Duration(milliseconds: 250),
              opacity: activated ? 1 : .4,
              child: SlideTransition(
                position: Tween<Offset>(
                        begin: Offset(0.0, .2), end: Offset.zero)
                    .animate(
                        CurvedAnimation(parent: controller, curve: _interval)),
                child: ScaleTransition(
                  scale: Tween<double>(begin: .9, end: 1.0).animate(
                      CurvedAnimation(parent: controller, curve: _interval)),
                  child: FadeTransition(
                    opacity:
                        CurvedAnimation(parent: controller, curve: _interval),
                    child: Container(
                      height: 100,
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        color: ColorTheme.whiteBlue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: InkWell(
                          onTap: () {
                            if (!activated) {
                              Helper.showConnectionSnackBar(context);
                              return;
                            }

                            BottomDialog bd = BottomDialog(context);
                            bd.show(DonationDialogWidget(
                              campaign: campaign,
                              defaultSelectedAmount: amount,
                              user: user,
                              context: context,
                              close: bd.close,
                            ));
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Material(
                                  color: ColorTheme.blue.withOpacity(.2),
                                  shape: CircleBorder(),
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      "DC",
                                      style: TextStyle(
                                          fontSize: 12, color: ColorTheme.blue),
                                    ),
                                  ),
                                ),
                                Text(
                                  "${amount}.00",
                                  style: _textTheme.headline6
                                      .copyWith(color: ColorTheme.blue),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
