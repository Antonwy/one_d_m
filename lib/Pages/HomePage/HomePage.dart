import 'package:flutter/material.dart';
import 'package:one_d_m/Components/NavBar.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/NavBarManager.dart';
import 'package:provider/provider.dart';

import 'ExplorePage.dart';
import 'NewsHomePage.dart';
import 'ProfilePage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController _pageController =
      PageController(initialPage: 1, viewportFraction: .99);

  @override
  Widget build(BuildContext context) {
    print("BUILD HOME");
    return Scaffold(
        backgroundColor: ColorTheme.white,
        body: Stack(
          children: <Widget>[
            PageView(
              controller: _pageController,
              children: <Widget>[
                NewsHomePage(() => _changePage(2)),
                ProfilePage(() => _changePage(2)),
                ExplorePage(),
              ],
            ),
            ChangeNotifierProvider(
              create: (context) => NavBarManager(_pageController),
              child: NavBar(_changePage),
            )
          ],
        ));
  }

  void _changePage(int page) {
    _pageController.animateToPage(page,
        duration: Duration(milliseconds: 250), curve: Curves.fastOutSlowIn);
  }
}
