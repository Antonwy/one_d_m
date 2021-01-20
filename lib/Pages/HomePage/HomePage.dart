import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ink_page_indicator/ink_page_indicator.dart';
import 'package:one_d_m/Components/NavBar.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/NavBarManager.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:provider/provider.dart';

import 'ExplorePage.dart';
import 'ProfilePage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  PageController _pageController = PageController(
    initialPage: 0,
    keepPage: false,
  );
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    if (Provider.of<UserManager>(context, listen: false).firstSignIn) {
      print("SHOW WELCOME");
      Future.delayed(Duration(seconds: 1)).then((v) => showWelcomeDialog());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ThemeManager.of(context).colors.light,
        body: Stack(
          children: <Widget>[
            PageView(
              controller: _pageController,
              onPageChanged: (page) {
                _resetPageScroll();
              },
              children: <Widget>[
                ProfilePage(
                  scrollController: _scrollController,
                  onExploreTapped: () => _changePage(1),
                ),
                // NewsHomePage(() => _changePage(2)),
                ExplorePage(
                  scrollController: _scrollController,
                ),
              ],
            ),
            ChangeNotifierProvider(
              create: (context) => NavBarManager(_pageController),
              child: NavBar(_changePage),
            )
          ],
        ));
  }

  void showWelcomeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        ThemeManager _theme = ThemeManager.of(context, listen: false);
        PageIndicatorController _controller = new PageIndicatorController();
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 350,
                width: context.screenWidth(),
                child: PageView(
                  controller: _controller,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset("assets/images/ic_flower.png"),
                        YMargin(12),
                        Text(
                          "Du hast 3 DV erhalten",
                          style: _theme.textTheme.dark.headline6,
                        ),
                        YMargin(6),
                        Text(
                          "Für jede Werbung die zwischen den Inhalten positioniert ist, erhältst Du ein paar Prozentpunkte. Jedes Mal wenn du 100% erreichst, bekommst du einen Donation Vote.",
                          style: _theme.textTheme.dark.bodyText2,
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          "assets/icons/ic_donation.png",
                        ),
                        YMargin(12),
                        Text(
                          "Spenden",
                          style: _theme.textTheme.dark.headline6,
                        ),
                        YMargin(6),
                        Text(
                          'Du kannst an Projekt und Sessions spenden indem du den "Unterstützen" Button in der rechten unteren Ecke drückst.',
                          style: _theme.textTheme.dark.bodyText2,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              InkPageIndicator(
                gap: 8,
                padding: 0,
                shape: IndicatorShape.circle(4),
                inactiveColor: ColorTheme.darkblue.withOpacity(.3),
                activeColor: ColorTheme.darkblue,
                inkColor: ColorTheme.darkblue,
                controller: _controller,
              ),
            ],
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                textColor: _theme.colors.dark,
                child: Text("Verstanden")),
          ],
        );
      },
    );
  }

  void _changePage(int page) {
    _pageController.animateToPage(page,
        duration: Duration(milliseconds: 200), curve: Curves.fastOutSlowIn);
    _resetPageScroll();
  }

  void _resetPageScroll() {
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
