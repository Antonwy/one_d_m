import 'package:flutter/material.dart';
import 'package:one_d_m/Components/NavBar.dart';
import 'package:one_d_m/Helper/Api.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:provider/provider.dart';
import 'ExplorePage.dart';
import 'FollowedProjects.dart';
import 'ProfilePage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextTheme textTheme, accentTextTheme;

  ThemeData theme;

  int _currentPage = 1;

  PageController _pageController = PageController(initialPage: 1);

  List<String> _pageNames = ["Home", "Entdecken", "Suchen", "Profil"];

  UserManager um;

  @override
  void initState() {
    fetchUser();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void fetchUser() async {
    User user = await Api.getUser();
    um.setUser(user);
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    textTheme = theme.textTheme;
    accentTextTheme = theme.accentTextTheme;

    um = Provider.of<UserManager>(context);

    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            PageView(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: <Widget>[
                FollowedProjects(),
                ProfilePage(),
                ExplorePage(),
              ],
            ),
            NavBar(
              _changePage,
              currentPage: _currentPage,
            )
          ],
        ));
  }

  void _changePage(int page) {
    if ((_currentPage - page).abs() == 2) {
      _pageController.jumpToPage(page);
    } else {
      _pageController.animateToPage(page,
          duration: Duration(milliseconds: 250), curve: Curves.fastOutSlowIn);
    }
  }
}
