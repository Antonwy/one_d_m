import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Components/BottomDialog.dart';
import 'package:one_d_m/Components/CampaignButton.dart';
import 'package:one_d_m/Components/UserButton.dart';
import 'package:one_d_m/Components/UserPageRoute.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Donation.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Pages/NewCampaignPage.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:transparent_image/transparent_image.dart';

class DonationWidget extends StatelessWidget {
  Donation donation;
  bool campaignPage, withUsername;

  DonationWidget(this.donation,
      {this.campaignPage = false, this.withUsername = true});
  TextTheme _textTheme;

  Future _future;

  MediaQueryData _mq;

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;
    _mq = MediaQuery.of(context);
    if (_future == null) _future = DatabaseService.getUser(donation.userId);

    return campaignPage ? _campaignPage() : _noCampaignPage();
  }

  Widget _campaignPage() {
    return FutureBuilder<User>(
      future: _future,
      builder: (context, snapshot) {
        User user = snapshot.data;
        return InkWell(
          onTap: user == null
              ? null
              : () {
                  Navigator.push(context, UserPageRoute(user));
                },
          child: Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(5),
            clipBehavior: Clip.antiAlias,
            color: Colors.transparent,
            child: Container(
              height: 250,
              child: Stack(
                children: <Widget>[
                  user?.imgUrl == null
                      ? Container(
                          height: 250,
                          width: double.infinity,
                          color: ColorTheme.donationWidget,
                          child: Center(
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : FadeInImage(
                          placeholder: MemoryImage(kTransparentImage),
                          image: CachedNetworkImageProvider(user?.imgUrl),
                          fit: BoxFit.cover,
                          height: 250,
                          width: double.infinity,
                        ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black54, Colors.transparent])),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "${snapshot.hasData ? "${user.firstname} ${user.lastname}" : "Laden..."}",
                                      style: _textTheme.body1.copyWith(
                                          color: ColorTheme.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "${timeago.format(donation.createdAt)}",
                                      style: _textTheme.caption.copyWith(
                                        color: ColorTheme.white.withAlpha(200),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "${donation.amount} DC",
                                style: _textTheme.body1.copyWith(
                                    color: ColorTheme.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _noCampaignPage() {
    double height = withUsername ? 250 : 250;
    return FutureBuilder<User>(
      future: _future,
      builder: (context, snapshot) {
        User user = snapshot.data;
        return InkWell(
          onTap: () {
            if (!withUsername) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (c) => NewCampaignPage(Campaign(
                          id: donation.campaignId,
                          imgUrl: donation.campaignImgUrl,
                          name: donation.campaignName))));
              return;
            }

            BottomDialog(context, duration: Duration(milliseconds: 125))
                .show(Material(
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              clipBehavior: Clip.antiAlias,
              color: ColorTheme.navBar,
              child: Padding(
                padding: EdgeInsets.only(
                    top: 10,
                    bottom: _mq.padding.bottom == 0 ? 10 : _mq.padding.bottom,
                    left: 10,
                    right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CampaignButton(
                      donation.campaignId,
                      color: ColorTheme.blue,
                      textStyle: _textTheme.title.copyWith(color: Colors.white),
                      elevation: 0,
                    ),
                    UserButton(
                      user.id,
                      user: user,
                      color: ColorTheme.blue,
                      elevation: 0,
                      textStyle: _textTheme.title.copyWith(color: Colors.white),
                    )
                  ],
                ),
              ),
            ));
          },
          child: Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(5),
            clipBehavior: Clip.antiAlias,
            child: Container(
              height: height,
              child: Stack(
                children: <Widget>[
                  donation.campaignImgUrl == null
                      ? Container(
                          height: height,
                          width: double.infinity,
                          color: ColorTheme.donationWidget,
                        )
                      : Image(
                          image: CachedNetworkImageProvider(
                              donation.campaignImgUrl),
                          fit: BoxFit.cover,
                          height: height,
                          width: double.infinity,
                        ),
                  withUsername
                      ? Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                  Colors.black87,
                                  Colors.transparent
                                ])),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                        height: 30,
                                        width: 30,
                                        child: Avatar(
                                            snapshot.data?.thumbnailUrl ??
                                                snapshot.data?.imgUrl)),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            "${snapshot.hasData ? "${user.firstname} ${user.lastname}" : "Laden..."}",
                                            style: _textTheme.body1.copyWith(
                                                color: ColorTheme.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "${timeago.format(donation.createdAt)}",
                                            style: _textTheme.caption.copyWith(
                                              color: ColorTheme.white
                                                  .withAlpha(200),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black54, Colors.transparent])),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  donation.campaignName,
                                  style: _textTheme.body1.copyWith(
                                      color: ColorTheme.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                "${donation.amount} DC",
                                style: _textTheme.body1.copyWith(
                                    color: ColorTheme.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
