import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:one_d_m/Components/DonationWidget.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/margin.dart';

import 'DatabaseService.dart';
import 'Donation.dart';
import 'ThemeManager.dart';

class LatestDonatorsView extends StatefulWidget {
  @override
  _LatestDonatorsViewState createState() => _LatestDonatorsViewState();
}

class _LatestDonatorsViewState extends State<LatestDonatorsView> {

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.screenHeight(percent: 0.10),
      child: StreamBuilder(
        stream: DatabaseService.getLatestDonations(limit: 30),
        builder: (_, snapshot) {
          if (!snapshot.hasData) return SizedBox.shrink();
          List<Donation> d = snapshot.data;
          if (d.isEmpty) return SizedBox.shrink();

          d.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          List<Widget> don = [];
          for (Donation dn in d) {
            don.add(_buildDonator(amount: dn.amount.toString(), uid: dn.userId));
          }

          return _buildCarousel(don);
        },
      ),
    );
  }

  Widget _buildDonator({String amount, String uid}) => Material(
        borderRadius: BorderRadius.circular(15),
        color: ThemeManager.of(context).colors.dark.withOpacity(.1),
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: context.screenWidth(percent: 0.21),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                            ThemeManager.of(context).colors.dark.withOpacity(0.5),
                      )),
            ],
          ),
        ),
      );

  Widget _buildCarousel(List<Widget> donators) => CarouselSlider(
      items: donators,
      options: CarouselOptions(
        height: context.screenHeight(percent: 0.2),
        viewportFraction: 0.23,
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

