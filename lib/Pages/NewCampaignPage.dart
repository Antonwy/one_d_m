import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/BottomDialog.dart';
import 'package:one_d_m/Components/DonationDialogWidget.dart';
import 'package:one_d_m/Components/DonationWidget.dart';
import 'package:one_d_m/Components/FollowButton.dart';
import 'package:one_d_m/Components/NewsPost.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Donation.dart';
import 'package:one_d_m/Helper/News.dart';
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

class _NewCampaignPageState extends State<NewCampaignPage> {
  TextTheme _textTheme;
  bool _subscribed = false;
  Campaign campaign;
  MediaQueryData _mq;
  ScrollController _scrollController;
  ValueNotifier _scrollOffset;

  Stream<Campaign> _campaignStream;
  Stream<List<Donation>> _donationStream;

  bool _subscribingLoading = false;
  bool _isAuthorOfCampaign = false;

  @override
  void initState() {
    _scrollController = widget.scrollController ?? ScrollController();

    _scrollOffset = ValueNotifier(0);

    _scrollController.addListener(() {
      _scrollOffset.value = _scrollController.offset;
    });

    _campaignStream = DatabaseService.getCampaignStream(widget.campaign.id);
    _donationStream =
        DatabaseService.getDonationFromCampaignStream(widget.campaign.id);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;
    _mq = MediaQuery.of(context);
    return Scaffold(
        floatingActionButton:
            Consumer<UserManager>(builder: (context, um, child) {
          return StreamBuilder<Campaign>(
              initialData: widget.campaign,
              stream: _campaignStream,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data.authorId != null) {
                  _isAuthorOfCampaign = snapshot.data.authorId == um.uid;
                }

                return FloatingActionButton.extended(
                    label: _isAuthorOfCampaign
                        ? Text("Post erstellen")
                        : Text("Spenden"),
                    onPressed: _isAuthorOfCampaign
                        ? () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (c) => CreateNewsPage(campaign)));
                          }
                        : () {
                            BottomDialog bd = BottomDialog(context);
                            bd.show(DonationDialogWidget(
                              campaign: snapshot.data,
                              user: um.user,
                              context: context,
                              close: bd.close,
                            ));
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
                            padding: EdgeInsets.all(18),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        campaign.name,
                                        style: _textTheme.title
                                            .copyWith(fontSize: 40),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Consumer<UserManager>(
                                        builder: (context, um, child) {
                                      return FollowButton(
                                        onPressed: () {
                                          _toggleSubscribed(um.uid);
                                        },
                                        followed: um
                                                .user?.subscribedCampaignsIds
                                                ?.contains(
                                                    widget.campaign.id) ??
                                            false,
                                      );
                                    }),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                IconTheme.merge(
                                  data: IconThemeData(color: Colors.black),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      _iconWidget(
                                          icon: Icons.location_on,
                                          desc: campaign.city == null
                                              ? null
                                              : campaign.city.split(",")[0]),
                                      _iconWidget(
                                          icon: Icons.attach_money,
                                          desc: "${campaign.amount} DC"),
                                      _iconWidget(
                                          icon: Icons.group,
                                          desc:
                                              "${campaign.subscribedCount} Abonennten"),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  campaign.description ?? "",
                                  style: _textTheme.body1.copyWith(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 18),
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
                                              style: _textTheme.title),
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
                                  padding: EdgeInsets.symmetric(horizontal: 18),
                                  sliver: SliverGrid.count(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 5,
                                    mainAxisSpacing: 5,
                                    childAspectRatio: 1.5,
                                    children: snapshot.data
                                        .map((d) => DonationWidget(
                                              d,
                                              campaignPage: true,
                                            ))
                                        .toList(),
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
                                          style: _textTheme.title),
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
                      child: Material(
                        clipBehavior: Clip.antiAlias,
                        shape: CircleBorder(),
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: IconButton(
                              icon: Icon(Icons.keyboard_arrow_down),
                              onPressed: () {
                                Navigator.pop(context);
                              }),
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

  void _toggleSubscribed(String uid) async {
    if (_subscribingLoading) return;
    _subscribingLoading = true;
    if (_subscribed)
      await DatabaseService.deleteSubscription(campaign, uid);
    else
      await DatabaseService.createSubscription(campaign, uid);
    _subscribed = !_subscribed;
    _subscribingLoading = false;
  }

  Widget _iconWidget({IconData icon, String desc}) {
    return Container(
      width: 100,
      child: Column(
        children: <Widget>[
          Icon(
            icon,
            size: 30,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            campaign.description == null ? "" : desc,
            textAlign: TextAlign.center,
            style: _textTheme.body1
                .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
