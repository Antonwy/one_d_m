import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/AnimatedFutureBuilder.dart';
import 'package:one_d_m/Components/BottomDialog.dart';
import 'package:one_d_m/Components/DonationDialogWidget.dart';
import 'package:one_d_m/Components/DonationWidget.dart';

import 'package:one_d_m/Components/NewsBody.dart';
import 'package:one_d_m/Components/UserPageRoute.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Donation.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/User.dart';

import 'package:one_d_m/Helper/UserManager.dart';
import 'package:provider/provider.dart';

class CampaignPage extends StatefulWidget {
  Campaign campaign;

  CampaignPage(this.campaign);

  @override
  _CampaignPageState createState() => _CampaignPageState();
}

class _CampaignPageState extends State<CampaignPage>
    with TickerProviderStateMixin {
  ThemeData theme;
  AnimationController _transitionAnim;

  UserManager um;
  Size displaySize;
  Campaign campaign;
  bool _isOwnPage = false,
      _loading = false,
      _subscribed = false,
      _subscribing = false;
  ScrollController _scrollController = ScrollController();

  GlobalKey _fabKey = GlobalKey();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Curve _transitionCurve = Curves.easeOut;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    campaign = widget.campaign;
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    um = Provider.of<UserManager>(context);
    displaySize = MediaQuery.of(context).size;

    return StreamBuilder<Campaign>(
        initialData: campaign.description != null ? campaign : null,
        stream: DatabaseService().getCampaignStream(campaign.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            campaign = snapshot.data;
            _isOwnPage = campaign.authorId == um.uid;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: 100,
                      child: Material(
                        color: Colors.white,
                        elevation: 10,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30)),
                      ),
                    ),
                    Material(
                      color: Colors.white,
                      clipBehavior: Clip.antiAlias,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30)),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(18, 10, 18, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: 10,
                            ),
                            _showAuthorAndDate(),
                            SizedBox(height: 5),
                            _showNameAndFollow(),
                            SizedBox(
                              height: 20,
                            ),
                            _campaignDetails(),
                            SizedBox(
                              height: 20,
                            ),
                            _description(),
                            SizedBox(
                              height: 20,
                            ),
                            _getCampaignDonations(),
                            _campaignNews(),
                            SizedBox(
                              height: 100,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  Widget _headerImage() {
    return Positioned(
        top: Tween<double>(end: 0, begin: displaySize.height)
            .animate(CurvedAnimation(
                parent: _transitionAnim,
                curve: Interval(.3, 1.0, curve: _transitionCurve)))
            .value,
        width: displaySize.width,
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          child: Container(
            height: displaySize.height * .35,
            width: displaySize.width,
            child: campaign.imgUrl != null
                ? Image(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(
                      campaign.imgUrl,
                    ),
                  )
                : Material(
                    color: Colors.grey[200],
                    child: Center(child: CircularProgressIndicator())),
          ),
        ));
  }

  Widget _deleteButton() {
    return _isOwnPage
        ? Positioned(
            right: 20,
            child: ScaleTransition(
              scale: CurvedAnimation(
                  parent: _transitionAnim,
                  curve: Interval(.4, 1, curve: _transitionCurve)),
              child: SafeArea(
                child: Material(
                  clipBehavior: Clip.antiAlias,
                  elevation: 10,
                  shape: CircleBorder(),
                  child: InkWell(
                    onTap: _deleteCampaign,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 12, 12, 12),
                      child: _loading
                          ? CircularProgressIndicator()
                          : Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          )
        : Container();
  }

  Widget _backButton() {
    return Positioned(
      left: 20,
      child: ScaleTransition(
        scale: CurvedAnimation(
            parent: _transitionAnim,
            curve: Interval(.2, .8, curve: _transitionCurve)),
        child: SafeArea(
          child: Material(
            clipBehavior: Clip.antiAlias,
            elevation: 10,
            shape: CircleBorder(),
            child: InkWell(
              onTap: _back,
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 12, 12, 12),
                child: Icon(Icons.close),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _back() {
    if (_transitionAnim.isAnimating) return;
    _transitionAnim.duration = Duration(milliseconds: 300);
    _transitionAnim.reverse().whenComplete(() {
      Navigator.pop(context);
    });
  }

  Widget _campaignNews() {
    return FutureBuilder<List<News>>(
        future: DatabaseService().getNewsFromCampaign(campaign),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.isEmpty) return Container();
            return _generateNews(snapshot.data);
          }
          return Container();
        });
  }

  Widget _description() {
    return Text(
      campaign.description,
      style: TextStyle(color: Colors.grey[600], fontSize: 18),
    );
  }

  Widget _showNameAndFollow() {
    return Container(
      width: MediaQuery.of(context).size.width - 36,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Text(
              campaign.name,
              style: theme.textTheme.title
                  .copyWith(fontSize: 30, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          _isOwnPage ? Container() : _followButton(),
        ],
      ),
    );
  }

  Widget _getCampaignDonations() {
    return StreamBuilder<List<Donation>>(
        stream: DatabaseService().getDonationFromCampaignStream(campaign.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Donation> donations = snapshot.data;
            if (donations.isEmpty) return Container();
            donations.sort((d1, d2) => d2.createdAt.compareTo(d1.createdAt));
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Aktuelle Spenden: ",
                  style: theme.textTheme.title,
                ),
                SizedBox(height: 10),
                ...donations.map((d) => DonationWidget(d)).toList()
              ],
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting)
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            );

          return Container();
        });
  }

  void _showCoins(c) {
    BottomDialog bd = BottomDialog(c);
    bd.show(DonationDialogWidget(
        close: bd.close, campaign: campaign, user: um.user, context: c));
  }

  Widget _followButton() {
    _subscribed = um.user.subscribedCampaignsIds.contains(campaign.id);
    return OutlineButton(
      onPressed: _subscribing ? null : _toggleSubscribed,
      highlightedBorderColor: _subscribed ? Colors.red : Colors.black,
      child: Text(
        _subscribed ? "Entfolgen" : "Folgen",
        style: TextStyle(color: _subscribed ? Colors.red : Colors.black),
      ),
    );
  }

  _deleteCampaign() async {
    if (await showDialog(
        context: context,
        child: AlertDialog(
          title: Text(
            "Löschen",
            style: TextStyle(color: Colors.red),
          ),
          content: Text(
              "Bist du dir sicher, dass du ${campaign.name} löschen willst?"),
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text("Abbrechen")),
            FlatButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text(
                  "Löschen",
                  style: TextStyle(color: Colors.red),
                )),
          ],
        ))) {
      setState(() {
        _loading = true;
      });
      await DatabaseService().deleteCampaign(campaign);
      _back();
    }
  }

  void _toggleSubscribed() async {
    setState(() {
      _subscribing = true;
    });
    if (_subscribed)
      await DatabaseService(um.uid).deleteSubscription(campaign);
    else
      await DatabaseService(um.uid).createSubscription(campaign);

    setState(() {
      _subscribing = false;
      _subscribed = !_subscribed;
    });
  }

  Widget _generateNews(List<News> news) {
    List<Widget> widgets = [];

    widgets.add(Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
          child: Text(
            "News: ",
            style: theme.textTheme.title,
          ),
        )));

    for (News n in news) {
      widgets.add(NewsBody(
        n,
      ));
    }

    return Column(
      children: widgets,
    );
  }

  Widget _details({IconData icon, String text}) => Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 35,
              ),
              SizedBox(height: 10),
              Text(
                text,
              ),
            ],
          ),
        ),
      );

  Widget _showAuthorAndDate() {
    return AnimatedFutureBuilder<User>(
        future: DatabaseService(campaign.authorId).getUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            User user = snapshot.data;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, UserPageRoute(user));
                  },
                  child: Text(
                    "${user.firstname} ${user.lastname}",
                    style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
                Text(Helper.getDate(campaign.createdAt))
              ],
            );
          }
          return Container(
            height: 20,
            width: 10,
          );
        });
  }

  Widget _campaignDetails() {
    return Container(
      width: displaySize.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _details(icon: Icons.map, text: campaign.city.split(",")[0]),
          _details(icon: Icons.monetization_on, text: "${campaign.amount} DC"),
          _details(
              icon: Icons.people,
              text: "${campaign.subscribedCount} Mitglieder"),
        ],
      ),
    );
  }
}
