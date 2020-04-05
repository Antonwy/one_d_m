import 'package:flutter/material.dart';
import 'package:one_d_m/Components/ValueAnimator.dart';
import 'package:one_d_m/Helper/NavPageManager.dart';
import 'package:provider/provider.dart';

class NavBar extends StatelessWidget {
  Function(int) changePage;

  NavBar(this.changePage);

  List<IconData> _iconList = [Icons.home, Icons.person, Icons.public];

  MediaQueryData _mq;

  BuildContext _context;

  @override
  Widget build(BuildContext context) {
    _context = context;
    _mq = MediaQuery.of(context);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 100,
        child: Stack(
          children: <Widget>[
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                      Colors.black.withOpacity(.7),
                      Colors.black.withOpacity(.32),
                      Colors.black.withOpacity(0)
                    ])),
              ),
            ),
            Center(
              child: Container(
                width: _mq.size.width * .7,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _generateIcons(),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Consumer<NavPageManager>(
                      builder: (context, npm, child) {
                        double pos = npm.position == null
                            ? 0
                            : (npm.position / _mq.size.width) - 1;
                        return Align(
                          alignment: Alignment(pos, 0),
                          child: child,
                        );
                      },
                      child: Container(
                        height: 5,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _generateIcons() {
    List<Widget> icons = [];

    for (int i = 0; i < _iconList.length; i++) {
      EdgeInsets padding;

      switch (i) {
        case 0:
          padding = EdgeInsets.only(left: 10);
          break;
        case 1:
          padding = EdgeInsets.only(left: 0);
          break;
        case 2:
          padding = EdgeInsets.only(right: 10);
          break;
      }

      icons.add(Padding(
        padding: padding,
        child: GestureDetector(
          onTap: () {
            changePage(i);
          },
          child: Icon(
            _iconList[i],
            size: 30,
            color: Colors.white,
          ),
        ),
      ));
    }

    return icons;
  }

  // List<Widget> _getIconList() {
  //   return List.generate(_iconList.length, (i) => i)
  //       .map<Widget>((i) =>
  //           _getIcon(icon: _iconList[i], page: i, active: currentPage == i))
  //       .toList();
  // }

  Widget _getIcon({IconData icon, int page, bool active = false}) {
    double width = MediaQuery.of(_context).size.width;
    double widthPerIcon = width / 3;
    return Positioned(
      left: widthPerIcon * page + (widthPerIcon / 2 - 25 / 2),
      child: GestureDetector(
        child: ValueAnimator(
            value: active ? 1.5 : 1.0,
            curve: Curves.fastOutSlowIn,
            duration: Duration(milliseconds: 250),
            builder: (value) {
              return Transform.scale(
                scale: value.toDouble(),
                child: Container(
                    width: 25,
                    height: 25,
                    child: Icon(
                      icon,
                      color:
                          active ? Colors.white : Colors.white.withOpacity(.8),
                      size: 25,
                    )),
              );
            }),
        onTap: () {
          changePage(page);
        },
      ),
    );
  }
}
