import 'package:flutter/material.dart';
import 'package:one_d_m/Components/NavBar.dart';
import 'package:one_d_m/Helper/NavBarManager.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/speed_scroll_physics.dart';
import 'package:provider/provider.dart';

import 'ExplorePage.dart';
import 'ProfilePage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  PageController _pageController =
      PageController(initialPage: 0, keepPage: false,);
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ThemeManager.of(context).colors.light,
        body: Stack(
          children: <Widget>[
            PageView(
              controller: _pageController,
              physics: CustomPageViewScrollPhysics(),
              onPageChanged:(page){
                _resetPageScroll();
              },
              children: <Widget>[
                ProfilePage(
                  scrollController: _scrollController,
                  onExploreTapped: () => _changePage(1),
                ),
                // NewsHomePage(() => _changePage(2)),
                ExplorePage(scrollController: _scrollController,),
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
        duration: Duration(milliseconds: 150), curve: Curves.linear);
    _resetPageScroll();


  }
  void _resetPageScroll(){
    _scrollController.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
