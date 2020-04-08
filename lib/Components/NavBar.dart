import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/NavPageManager.dart';
import 'package:provider/provider.dart';

class NavBar extends StatefulWidget {
  Function(int) changePage;
  AnimationController controller;

  NavBar(this.changePage, {this.controller});

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> with SingleTickerProviderStateMixin {
  List<IconData> _iconList = [Icons.home, Icons.person, Icons.public];

  MediaQueryData _mq;

  AnimationController _controller;

  NavPageManager _npm;

  bool _isOpen = false;

  double _openHeight, _closeHeight, _lastPosition = 0.0;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 125))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _isOpen = _controller.value == 0;
            }
          });
    super.initState();
  }

  Future<void> open() async {
    await _controller.forward();
    _isOpen = true;
  }

  Future<void> close() async {
    await _controller.reverse();
    _isOpen = false;
  }

  Future<void> _openNavBar() async {
    await open();
    do {
      _lastPosition = _npm.position;
      await Future.delayed(Duration(seconds: 2));
    } while (_lastPosition != _npm.position && _isOpen);
    await close();
  }

  void shouldOpenCheck() {
    if (!_isOpen) _openNavBar();
  }

  @override
  Widget build(BuildContext context) {
    _mq = MediaQuery.of(context);
    _npm = Provider.of<NavPageManager>(context);

    _openHeight = _mq.padding.bottom == 0 ? 50 : 55 + _mq.padding.bottom;
    _closeHeight = _mq.padding.bottom == 0 ? 30 : _mq.padding.bottom;
    double pos = _npm.position - 1;

    shouldOpenCheck();

    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              GestureDetector(
                onTap: _openNavBar,
                child: Container(
                    height: Tween<double>(begin: _closeHeight, end: _openHeight)
                        .animate(_controller)
                        .value,
                    width: _mq.size.width,
                    child: Material(
                      elevation: 30,
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(
                              Tween<double>(begin: 25.0, end: 30.0)
                                  .animate(_controller)
                                  .value)),
                      clipBehavior: Clip.antiAlias,
                      color: Colors.indigo,
                    )),
              ),
              Container(
                  height: Tween<double>(begin: _closeHeight, end: _openHeight)
                      .animate(_controller)
                      .value,
                  width: _mq.size.width,
                  child: Opacity(
                    opacity:
                        Tween(begin: 0.0, end: 1.0).animate(_controller).value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Container(
                          width: _mq.size.width * .75,
                          margin: EdgeInsets.only(bottom: 5),
                          child: Align(
                              alignment: Alignment(pos, 0),
                              child: Container(
                                width: 40,
                                height: 40,
                                child: Center(
                                  child: Container(
                                    width: Tween(begin: 0.0, end: 40.0)
                                        .animate(_controller)
                                        .value,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle),
                                  ),
                                ),
                              )),
                        ),
                        Center(
                          child: Container(
                            margin: EdgeInsets.only(bottom: 5),
                            width: _mq.size.width * .75,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: _generateIcons(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          );
        },
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
          child: GestureDetector(
              onTap: () {
                widget.changePage(i);
              },
              child: Container(
                width: 30,
                height: 30,
                child: Opacity(
                  opacity: Tween<double>(begin: 1.0, end: .5)
                      .transform(_getAnimatedValue(i, _npm.position)),
                  child: ScaleTransition(
                    scale: Tween(begin: 0.0, end: 1.0).animate(_controller),
                    child: Icon(
                      _iconList[i],
                      color: ColorTween(begin: Colors.indigo, end: Colors.white)
                          .transform(_getAnimatedValue(i, _npm.position)),
                    ),
                  ),
                ),
              ))));
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
