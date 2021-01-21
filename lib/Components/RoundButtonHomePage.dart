import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/CircularRevealRoute.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';

class RoundButtonHomePage extends StatelessWidget {
  final IconData icon;
  final Widget toPage;
  final bool dark;
  Function onTap;
  final GlobalKey _key = GlobalKey();
  final Color toColor;

  RoundButtonHomePage(
      {this.icon,
      this.toPage,
      this.toColor = Colors.white,
      this.onTap,
      this.dark = false});

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return Container(
      key: _key,
      width: 50,
      height: 50,
      child: Material(
        clipBehavior: Clip.antiAlias,
        color: dark ? _theme.colors.dark : _theme.colors.contrast,
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
            size: 28,
            color: dark ? _theme.colors.contrast : _theme.colors.dark,
          ),
        ),
      ),
    );
  }
}
