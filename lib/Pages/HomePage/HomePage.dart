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
  PageController _pageController = PageController(initialPage: 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorTheme.white,
        body: Stack(
          children: <Widget>[
            // Positioned(
            //   top: 0,
            //   left: 0,
            //   right: 0,
            //   height: 280,
            //   child: CustomPaint(
            //     painter: PathPainter(),
            //   ),
            // ),
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

class PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Gradient gradient = new LinearGradient(
        colors: <Color>[ColorTheme.red, ColorTheme.red.withOpacity(.6)],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight);

    Paint paint = Paint()
      ..shader =
          gradient.createShader(Rect.fromLTRB(0, 0, size.width, size.height));

    Path path = Path();

    path.cubicTo(size.width / 4, 3 * size.height / 4, 3 * size.width / 4,
        size.height / 4, size.width, size.height);

    path.lineTo(size.width, 0);

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
