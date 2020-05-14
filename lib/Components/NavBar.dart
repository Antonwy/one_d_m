import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/NavBarManager.dart';
import 'package:provider/provider.dart';

class NavBar extends StatefulWidget {
  Function(int) changePage;

  NavBar(this.changePage);

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  List<IconData> _iconList = [Icons.inbox, Icons.home, Icons.public];

  MediaQueryData _mq;

  NavBarManager _npm;

  Duration _animDuration = Duration(milliseconds: 500);

  double _openHeight, _closeHeight;

  NavBarState _state = NavBarState.open;

  void open() {
    setState(() {
      _state = NavBarState.open;
    });
  }

  void close() {
    setState(() {
      _state = NavBarState.collapsed;
    });
  }

  void toggle() {
    if (_state == NavBarState.collapsed)
      open();
    else
      close();
  }

  @override
  Widget build(BuildContext context) {
    _mq = MediaQuery.of(context);

    _openHeight = _mq.padding.bottom == 0 ? 50 : 55 + _mq.padding.bottom;
    _closeHeight = _mq.padding.bottom == 0 ? 30 : _mq.padding.bottom;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          GestureDetector(
            onTap: toggle,
            child: AnimatedContainer(
                duration: _animDuration,
                height: _state == NavBarState.open ? _openHeight : _closeHeight,
                width: _mq.size.width,
                curve: Curves.fastLinearToSlowEaseIn,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: ColorTheme.black.withOpacity(.10),
                          blurRadius: 30,
                          offset: Offset(0, -5)),
                    ],
                    color: ColorTheme.navBar,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30))),
                child: AnimatedOpacity(
                  curve: Curves.fastLinearToSlowEaseIn,
                  duration: _animDuration,
                  opacity: _state != NavBarState.open ? 0.0 : 1.0,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Container(
                        width: _mq.size.width * .75,
                        margin: EdgeInsets.only(bottom: 5),
                        child: Consumer<NavBarManager>(
                            builder: (context, npm, child) {
                          return Align(
                              alignment: Alignment(npm.position - 1, 0),
                              child: Container(
                                width: 40,
                                height: 40,
                                child: Center(
                                  child: AnimatedContainer(
                                    curve: Curves.fastLinearToSlowEaseIn,
                                    duration: _animDuration,
                                    height:
                                        _state != NavBarState.open ? 0.0 : 40,
                                    decoration: BoxDecoration(
                                        color: ColorTheme.navBarHighlight,
                                        shape: BoxShape.circle),
                                  ),
                                ),
                              ));
                        }),
                      ),
                      Center(
                        child: Container(
                          margin: EdgeInsets.only(bottom: 5),
                          width: _mq.size.width * .75,
                          child: Consumer<NavBarManager>(
                              builder: (context, npm, child) {
                            _npm = npm;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: _generateIcons(),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }

  List<Widget> _generateIcons() {
    List<Widget> icons = [];

    for (int i = 0; i < _iconList.length; i++) {
      EdgeInsets padding;

      switch (i) {
        case 0:
          padding = EdgeInsets.only(left: 5);
          break;
        case 1:
          padding = EdgeInsets.only(left: 0);
          break;
        case 2:
          padding = EdgeInsets.only(right: 5);
          break;
      }

      icons.add(Padding(
          padding: padding,
          child: IgnorePointer(
            ignoring: _state == NavBarState.collapsed,
            child: GestureDetector(
                onTap: () {
                  widget.changePage(i);
                },
                child: Container(
                  width: 30,
                  height: 30,
                  child: Opacity(
                    opacity: Tween<double>(begin: 1.0, end: .5)
                        .transform(_getAnimatedValue(i, _npm?.position ?? 1.0)),
                    child: Icon(
                      _iconList[i],
                      color: ColorTween(
                              begin: ColorTheme.navBar,
                              end: ColorTheme.navBarDisabled)
                          .transform(
                              _getAnimatedValue(i, _npm?.position ?? 1.0)),
                    ),
                  ),
                )),
          )));
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
