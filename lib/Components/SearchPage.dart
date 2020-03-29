import 'package:flutter/material.dart';

import 'SearchResultsList.dart';

class SearchPage extends StatefulWidget {
  Size size;
  Offset offset;

  SearchPage({this.size, this.offset});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  Offset _offset;
  Size _size;
  AnimationController _controller;
  AnimationController _fadeController;
  Size _displaySize;
  String _query = "";
  CurvedAnimation _curvedAnimation;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));

    _curvedAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _fadeController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));

    _controller.forward().whenComplete(() {
      _fadeController.forward();
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _offset = widget.offset;
    _size = widget.size;
    _displaySize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: <Widget>[
          AnimatedBuilder(
              animation: _controller,
              builder: (context, snapshot) {
                return Positioned(
                  top: Tween(begin: _offset.dy, end: 0.0)
                      .animate(_curvedAnimation)
                      .value,
                  left: Tween(begin: _offset.dx, end: 0.0)
                      .animate(_curvedAnimation)
                      .value,
                  child: Container(
                    width: Tween(begin: _size.width, end: _displaySize.width)
                        .animate(_curvedAnimation)
                        .value,
                    height: Tween(begin: _size.height, end: _displaySize.height)
                        .animate(_curvedAnimation)
                        .value,
                    child: Material(
                      elevation: 1,
                      borderRadius: BorderRadius.circular(4.0),
                      color: Colors.white,
                    ),
                  ),
                );
              }),
          AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Positioned(
                  left: _offset.dx,
                  top: Tween(
                          begin: _offset.dy,
                          end: MediaQuery.of(context).padding.top)
                      .animate(_curvedAnimation)
                      .value,
                  child: SizedBox(
                      width: _size.width,
                      height: _size.height,
                      child: Card(
                        margin: EdgeInsets.zero,
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: <Widget>[
                            ScaleTransition(
                              scale: _controller,
                              child: IconButton(
                                icon: Icon(Icons.arrow_back_ios),
                                onPressed: () {
                                  if (_controller.isAnimating) return;
                                  _fadeController.reverse().whenComplete(() {
                                    _controller.reverse().whenComplete(() {
                                      Navigator.pop(context);
                                    });
                                  });
                                },
                              ),
                            ),
                            Positioned(
                                left: Tween(begin: 16.0, end: 50.0)
                                    .animate(_controller)
                                    .value,
                                child: Container(
                                    width: _size.width - 100,
                                    child: TextField(
                                      decoration: InputDecoration.collapsed(
                                        hintText: "Suchen",
                                      ),
                                      onChanged: (text) {
                                        setState(() {
                                          _query = text;
                                        });
                                      },
                                    ))),
                          ],
                        ),
                      )),
                );
              }),
          Positioned(
            top: MediaQuery.of(context).padding.top + _size.height + 20,
            child: FadeTransition(
              opacity: _fadeController,
              child: Container(
                width: _displaySize.width,
                height: _displaySize.height -
                    (MediaQuery.of(context).padding.top + _size.height),
                child: SearchResultsList(_query),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
