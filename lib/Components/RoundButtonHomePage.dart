import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/CircularRevealRoute.dart';
import 'package:one_d_m/Helper/Helper.dart';

class RoundButtonHomePage extends StatelessWidget {
  final IconData icon;
  final Widget toPage;
  Function onTap;
  final GlobalKey _key = GlobalKey();
  final Color toColor;

  RoundButtonHomePage(
      {this.icon, this.toPage, this.toColor = Colors.white, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _key,
      width: 50,
      height: 50,
      child: Material(
        clipBehavior: Clip.antiAlias,
        color: Colors.indigo,
        shape: CircleBorder(),
        child: InkWell(
          onTap: () {
            if (toPage == null) {
              onTap();
              return;
            }
            Navigator.push(
                context,
                CircularRevealRoute(
                    page: toPage,
                    offset: Helper.getCenteredPositionFromKey(_key),
                    startColor: Colors.indigo,
                    color: toColor));
          },
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
