import 'package:flutter/material.dart';
import 'package:one_d_m/Components/NavBar.dart';
import 'package:one_d_m/Helper/NavPageManager.dart';
import 'package:provider/provider.dart';

import 'ExplorePage.dart';
import 'FollowedProjects.dart';
import 'ProfilePage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController _pageController = PageController(initialPage: 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            PageView(
              controller: _pageController,
              children: <Widget>[
                FollowedProjects(() => _changePage(2)),
                ProfilePage(() => _changePage(2)),
                ExplorePage(),
              ],
            ),
            ChangeNotifierProvider(
              create: (context) => NavPageManager(_pageController),
              child: NavBar(
                _changePage,
              ),
            )
          ],
        ));
  }

  void _changePage(int page) {
    _pageController.animateToPage(page,
        duration: Duration(milliseconds: 250), curve: Curves.fastOutSlowIn);
  }
}
