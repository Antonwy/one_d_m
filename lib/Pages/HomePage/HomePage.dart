import 'package:flutter/material.dart';
import 'package:one_d_m/Components/ApiBuilder.dart';
import 'package:one_d_m/Components/ErrorText.dart';
import 'package:one_d_m/Components/NavBar.dart';
import 'package:one_d_m/Helper/API/Api.dart';
import 'package:one_d_m/Helper/API/ApiResult.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/RegisterPage.dart';
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

  PageController _pageController =
      PageController(initialPage: 1, keepPage: true);

  UserManager um;

  Future<ApiResult> _future;

  @override
  void initState() {
    super.initState();
    _future = Api.getUser();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
            ApiBuilder<User>(
                future: _future,
                success: (context, user) {
                  um.setUser(user);
                  return PageView(
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
                  );
                },
                error: (context, message) {
                  if (message == "Unauthorized") {
                    _logout();
                  }
                  return Center(
                      child: ErrorText(message));
                },
                loading: Center(
                  child: CircularProgressIndicator(),
                )),
            NavBar(
              _changePage,
              currentPage: _currentPage,
            )
          ],
        ));
  }

  void _logout() async {
    Api.logout();
    Navigator.push(context, MaterialPageRoute(builder: (c) => RegisterPage()));
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
