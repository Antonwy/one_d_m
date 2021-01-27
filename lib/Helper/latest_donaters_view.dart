import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:infinite_listview/infinite_listview.dart';
import 'package:one_d_m/Components/DonationWidget.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/margin.dart';

import 'Constants.dart';
import 'DatabaseService.dart';
import 'Donation.dart';
import 'ThemeManager.dart';

class LatestDonatorsView extends StatefulWidget {
  @override
  _LatestDonatorsViewState createState() => _LatestDonatorsViewState();
}

class _LatestDonatorsViewState extends State<LatestDonatorsView> {
  final InfiniteScrollController _infiniteController = InfiniteScrollController(
    initialScrollOffset: 0.0,
  );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DatabaseService.getLatestDonations(limit: 5),
      builder: (_, snapshot) {
        if (!snapshot.hasData) return SizedBox.shrink();
        List<Donation> d = snapshot.data;
        List<Donation> ud = [];
        List<String> userIds = [];
        if (d.isEmpty) return SizedBox.shrink();

        d.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        d.forEach((element) {
          userIds.add(element.userId);
        });
        userIds = userIds.toSet().toList();

        userIds.forEach((id) {
          Donation dm = d.firstWhere((element) => element.userId == id);
          ud.add(dm);
        });
        List<Widget> don = [];
        for (Donation d in ud) {
          don.add(_buildDonator(amount: d.amount.toString(), uid: d.userId));
        }

        return _buildCarousel(don);
      },
    );
  }

  Widget _buildDonator({String amount, String uid}) => Material(
        borderRadius: BorderRadius.circular(Constants.radius + 2),
        color: ThemeManager.of(context).colors.contrast.withOpacity(.6),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            FutureBuilder(
                future: DatabaseService.getUser(uid),
                builder: (context, snapshot) {
                  User u = snapshot.data;
                  return Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: RoundedAvatar(
                      u?.thumbnailUrl ?? u?.imgUrl,
                      height: 31,
                      loading: !snapshot.hasData,
                    ),
                  );
                }),
            Text('${amount}DV',
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                      fontWeight: FontWeight.w700,
                      color:
                          ThemeManager.of(context).colors.dark.withOpacity(0.7),
                    )),
          ],
        ),
      );

  Widget _buildCarousel(List<Widget> donators) => CarouselSlider(
      items: donators,
      options: CarouselOptions(
        height: 90,
        viewportFraction: 0.2,
        initialPage: 0,
        enableInfiniteScroll: true,
        reverse: false,
        autoPlay: true,
        pauseAutoPlayInFiniteScroll: false,
        pauseAutoPlayOnTouch: false,
        pauseAutoPlayOnManualNavigate: false,
        autoPlayInterval: Duration(milliseconds: 9000),
        autoPlayAnimationDuration: Duration(milliseconds: 9000),
        autoPlayCurve: Curves.linear,
        enlargeCenterPage: false,
        scrollDirection: Axis.horizontal,
      ));
}

class LatestDonator {
  String amount;
  String imgUrl;

  LatestDonator({this.amount, this.imgUrl});
}
