import 'package:flutter/material.dart';
import 'package:one_d_m/Components/ValueAnimator.dart';

class NavBar extends StatelessWidget {
  Function(int) changePage;
  int currentPage;

  List<IconData> _iconList = [Icons.home, Icons.person, Icons.public];

  NavBar(this.changePage, {this.currentPage});

  BuildContext _context;

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 110,
        child: Stack(
          children: <Widget>[
            Container(
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
            Center(
              child: Stack(
                children: _getIconList(),
                alignment: Alignment.centerLeft,
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 250),
              curve: Curves.fastOutSlowIn,
              bottom: 20,
              left: (MediaQuery.of(context).size.width / 3) * currentPage +
                  (MediaQuery.of(context).size.width / 3) / 2 -
                  25,
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
    );
  }

  List<Widget> _getIconList() {
    return List.generate(_iconList.length, (i) => i)
        .map<Widget>((i) =>
            _getIcon(icon: _iconList[i], page: i, active: currentPage == i))
        .toList();
  }

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
                      color: active ? Colors.white : Colors.white.withOpacity(.8),
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
