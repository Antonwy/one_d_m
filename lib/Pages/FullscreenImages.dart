import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ink_page_indicator/ink_page_indicator.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';

class FullscreenImages extends StatelessWidget {
  final List<String> imgUrls;
  PageIndicatorController _pageController = PageIndicatorController();

  FullscreenImages(this.imgUrls);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.whiteBlue,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: imgUrls.length,
              itemBuilder: (context, index) =>
                  Center(child: CachedNetworkImage(imageUrl: imgUrls[index])),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: EdgeInsets.only(bottom: 15),
              child: InkPageIndicator(
                gap: 18,
                padding: 0,
                shape: IndicatorShape.circle(6),
                inactiveColor: ColorTheme.blue.withOpacity(.5),
                activeColor: ColorTheme.blue,
                inkColor: ColorTheme.blue,
                controller: _pageController,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: ColorTheme.whiteBlue,
              elevation: 0,
              iconTheme: IconThemeData(color: ColorTheme.blue),
            ),
          ),
        ],
      ),
    );
  }
}
