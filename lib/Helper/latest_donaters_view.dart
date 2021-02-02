import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:one_d_m/Components/CustomOpenContainer.dart';
import 'package:one_d_m/Components/DonationWidget.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:one_d_m/Pages/UserPage.dart';

import 'Constants.dart';
import 'DatabaseService.dart';
import 'Donation.dart';
import 'ThemeManager.dart';

class LatestDonatorsView extends StatefulWidget {
  @override
  _LatestDonatorsViewState createState() => _LatestDonatorsViewState();
}

class _LatestDonatorsViewState extends State<LatestDonatorsView> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(height: 90, child: _buildDonators());
  }

  Widget _buildDonators() => StreamBuilder(
        stream: DatabaseService.getLatestDonations(limit: 20),
        builder: (_, snapshot) {
          if (!snapshot.hasData) return SizedBox.shrink();
          List<Donation> d = snapshot.data;
          if (d.isEmpty) return SizedBox.shrink();
          return ListView.separated(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            separatorBuilder: (context, index) => SizedBox(
              width: 8,
            ),
            itemCount: d.length,
            itemBuilder: (_, index) {
              return Padding(
                padding: EdgeInsets.only(
                    left: index == 0 ? 12.0 : 0.0,
                    right: index == d.length - 1 ? 12.0 : 0.0),
                child: _buildDonator(
                    amount: d[index].amount.toString(), uid: d[index].userId),
              );
            },
          );
        },
      );

  Widget _buildDonator({String amount, String uid}) => FutureBuilder<User>(
      future: DatabaseService.getUser(uid),
      builder: (context, snapshot) {
        User u = snapshot.data;
        return CustomOpenContainer(
          openBuilder: (context, close, scrollController) => UserPage(
            u,
            scrollController: scrollController,
          ),
          tappable: u != null,
          closedElevation: 0,
          closedColor: ThemeManager.of(context).colors.contrast.withOpacity(.6),
          closedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.radius + 2)),
          closedBuilder: (context, open) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: RoundedAvatar(
                  u?.thumbnailUrl ?? u?.imgUrl,
                  height: 31,
                  loading: !snapshot.hasData,
                  name: u?.name,
                ),
              ),
              Text('${amount}DV',
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                        fontWeight: FontWeight.w700,
                        color: ThemeManager.of(context)
                            .colors
                            .dark
                            .withOpacity(0.7),
                      )),
            ],
          ),
        );
      });

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
