import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/ApiBuilder.dart';
import 'package:one_d_m/Components/ErrorText.dart';
import 'package:one_d_m/Components/NavBar.dart';
import 'package:one_d_m/Helper/API/ApiResult.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
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
      PageController(initialPage: 1, viewportFraction: .99);

  UserManager um;

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
            StreamBuilder<DocumentSnapshot>(
                stream: DatabaseService(um.uid).userReference.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data.exists) {
                    um.user = User.fromSnapshot(snapshot.data);
                    return PageView(
                      controller: _pageController,
                      onPageChanged: (page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      children: <Widget>[
                        FollowedProjects(() => _changePage(2)),
                        ProfilePage(() => _changePage(2)),
                        ExplorePage(),
                      ],
                    );
                  } else if (!snapshot.hasData && !snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return Center(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ErrorText(
                          "Etwas ist schief gelaufen! Versuche es später erneut!"),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RaisedButton(
                            onPressed: () {
                              setState(() {});
                            },
                            color: Colors.red,
                            child: Text(
                              "Erneut laden",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(width: 10),
                          RaisedButton(
                            onPressed: () {
                              um.logout();
                            },
                            color: Colors.red,
                            child: Text(
                              "Logout",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ],
                  ));
                }),
            NavBar(
              _changePage,
              currentPage: _currentPage,
            )
          ],
        ));
  }

  void _logout() async {
    um.logout();
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
