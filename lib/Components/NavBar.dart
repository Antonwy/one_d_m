import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/helper.dart';
import 'package:one_d_m/provider/navbar_manager.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:provider/provider.dart';

class NavBar extends StatefulWidget {
  Function(int) changePage;

  NavBar(this.changePage);

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  List<IconData> _iconList = [
    // CupertinoIcons.checkmark_seal,
    Icons.home_rounded,
    Icons.public
  ];

  MediaQueryData _mq;

  NavBarManager _npm;

  double _openHeight;

  @override
  Widget build(BuildContext context) {
    BaseTheme _bTheme = ThemeManager.of(context).colors;
    _mq = MediaQuery.of(context);

    _openHeight = _mq.padding.bottom == 0 ? 75 : 55 + _mq.padding.bottom;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
          height: _openHeight,
          width: _mq.size.width,
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: ColorTheme.black.withOpacity(.2),
                    blurRadius: 30,
                    offset: Offset(0, -5)),
              ],
              color: ColorTheme.appBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          child: Padding(
            padding: EdgeInsets.only(bottom: _mq.padding.bottom == 0 ? 0 : 5),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: _mq.size.width * 0.6,
                      child: Consumer<NavBarManager>(
                          builder: (context, npm, child) {
                        return Align(
                          alignment: Alignment(
                              Helper.mapValue(npm.position, 0, 1, -1, 1), 0),
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                color: _bTheme.dark, shape: BoxShape.circle),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                Positioned.fill(
                  child:
                      Consumer<NavBarManager>(builder: (context, npm, child) {
                    _npm = npm;
                    return Center(
                      child: Container(
                        width: _mq.size.width * .6,
                        height: _mq.size.height,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: _generateIcons()),
                      ),
                    );
                  }),
                ),
              ],
            ),
          )),
    );
  }

  List<Widget> _generateIcons() {
    List<Widget> icons = [];
    List<Alignment> alignments = [Alignment.centerLeft, Alignment.centerRight];

    for (int i = 0; i < _iconList.length; i++) {
      icons.add(Expanded(
        child: GestureDetector(
          onTap: () {
            widget.changePage(i);
          },
          child: Container(
            alignment: alignments[i],
            height: double.infinity,
            color: Colors.transparent,
            margin:
                EdgeInsets.only(left: i == 0 ? 8 : 0, right: i == 1 ? 8 : 0),
            child: Container(
              child: Opacity(
                opacity: Tween<double>(begin: 1.0, end: .5)
                    .transform(_getAnimatedValue(i, _npm?.position ?? 1.0)),
                child: Icon(
                  _iconList[i],
                  color: ColorTween(
                          begin: ColorTheme.navBar,
                          end: ColorTheme.navBarDisabled)
                      .transform(_getAnimatedValue(i, _npm?.position ?? 1.0)),
                ),
              ),
            ),
          ),
        ),
      ));
    }

    return icons;
  }

  double _getAnimatedValue(int index, double position) {
    double value = (index - position).abs();
    if (value <= 1.0 && value >= 0)
      return value;
    else
      return 1;
  }
}

enum NavBarState { collapsed, open, page }
