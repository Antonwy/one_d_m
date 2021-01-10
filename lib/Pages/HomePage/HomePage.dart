import 'package:flutter/material.dart';
import 'package:one_d_m/Components/NavBar.dart';
import 'package:one_d_m/Helper/NavBarManager.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:provider/provider.dart';

import 'ExplorePage.dart';
import 'ProfilePage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ThemeManager.of(context).colors.light,
        body: Stack(
          children: <Widget>[
            PageView(
              controller: _pageController,
              children: <Widget>[
                ProfilePage(
                  onExploreTapped: () => _changePage(1),
                ),
                // NewsHomePage(() => _changePage(2)),
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
        duration: Duration(milliseconds: 150), curve: Curves.fastOutSlowIn);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
