import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class NavBarSheet {
  final BuildContext context;
  final ValueNotifier<bool> _notifier = ValueNotifier(true);
  final Duration duration;
  final Curve curve;
  final String topImage;

  NavBarSheet(this.context,
      {this.duration = const Duration(milliseconds: 500),
      this.curve = Curves.easeInOut,
      this.topImage});

  static NavBarSheet of(BuildContext context) {
    return NavBarSheet(context);
  }

  NavBarSheet withTopImage(String imgUrl) {
    return NavBarSheet(this.context,
        duration: this.duration, curve: this.curve, topImage: imgUrl);
  }

  Future<void> show(Widget widget) async {
    await Navigator.push(
        context,
        PageRouteBuilder(
            opaque: false,
            transitionDuration: Duration.zero,
            pageBuilder: (c, animOne, animTwo) => _Dialog(widget,
                open: _notifier,
                duration: duration,
                curve: curve,
                topImage: topImage)));
  }

  void close() {
    _notifier.value = false;
  }
}

class _Dialog extends StatefulWidget {
  final Widget child;
  final ValueNotifier<bool> open;
  final Duration duration;
  final Curve curve;
  final String topImage;

  _Dialog(this.child, {this.open, this.duration, this.curve, this.topImage});

  @override
  __DialogState createState() => __DialogState();
}

class __DialogState extends State<_Dialog> with SingleTickerProviderStateMixin {
  Size _displaySize;

  AnimationController _controller;

  ScrollController _scrollController = ScrollController();

  bool _scrollingEnabled = true;

  VelocityTracker _vt = VelocityTracker();

  double _sheetHeight, _scrolledHeight = 0.0;

  @override
  void initState() {
    super.initState();

    widget.open.addListener(() {
      if (!widget.open.value) close();
    });

    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final GlobalKey _childKey = GlobalKey();

  double get _childHeight {
    final RenderBox renderBox = _childKey.currentContext.findRenderObject();
    return renderBox.size.height;
  }

  bool get _isOpen => _controller.value == 1.0;

  void _handleDragUpdate(double dy) {
    if (!_scrollingEnabled && (_displaySize.height * .7) - _sheetHeight >= 0) {
      _controller.value -= (dy / (_childHeight ?? dy)) * .5;
    }

    if (_isOpen && _scrollController.offset <= 0) {
      setState(() {
        if (dy < 0) {
          if ((_displaySize.height * .7 + 250 - 25) - _sheetHeight > 0.0) {
            _scrolledHeight -= dy;
            _scrollingEnabled = false;
          } else {
            _scrollingEnabled = true;
          }
        } else {
          _scrolledHeight -= dy;
          _scrollingEnabled = false;
        }
      });
    }
  }

  void _handleDragEnd(Velocity velocity) {
    if (_isOpen && _scrollingEnabled) return;

    if (velocity.pixelsPerSecond.dy > 700) {
      final double flingVelocity = -velocity.pixelsPerSecond.dy / _childHeight;
      if (_controller.value > 0.0) {
        _controller.fling(velocity: flingVelocity);
      }
      if (flingVelocity < 0.0) {
        close();
      }
    } else if (_controller.value < .5) {
      if (_controller.value > 0.0) _controller.fling(velocity: -1.0);
      close();
    } else {
      _controller.forward();
    }
  }

  _pop() {
    Navigator.pop(context);
  }

  close() {
    _controller.duration = Duration(milliseconds: 250);
    _controller.reverse().whenComplete(() {
      _pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    _displaySize = MediaQuery.of(context).size;
    _sheetHeight = _displaySize.height * .7 + _scrolledHeight;

    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: close,
          child: AnimatedBuilder(
              animation: _controller,
              builder: (context, snapshot) {
                return Container(
                  height: _displaySize.height,
                  width: _displaySize.width,
                  color: ColorTween(
                          begin: Colors.black.withOpacity(0),
                          end: Colors.black.withOpacity(.5))
                      .animate(_controller)
                      .value,
                );
              }),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Listener(
            onPointerDown: (PointerDownEvent event) {
              _vt.addPosition(event.timeStamp, event.position);
            },
            onPointerMove: (PointerMoveEvent event) {
              _vt.addPosition(event.timeStamp, event.position);
              _handleDragUpdate(event.delta.dy);
            },
            onPointerUp: (PointerUpEvent event) {
              _handleDragEnd(_vt.getVelocity());
            },
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return GestureDetector(
                  onVerticalDragUpdate: (DragUpdateDetails details) {
                    _handleDragUpdate(details.primaryDelta);
                  },
                  onVerticalDragEnd: (DragEndDetails details) {
                    _handleDragEnd(details.velocity);
                  },
                  child: Stack(
                    children: <Widget>[
                      widget.topImage != null
                          ? Positioned(
                              bottom: Tween<double>(
                                      begin: -250 +
                                          MediaQuery.of(context).padding.bottom,
                                      end: _displaySize.height * .7 - 25)
                                  .animate(CurvedAnimation(
                                      parent: _controller,
                                      curve: Interval(.5, 1.0)))
                                  .value,
                              child: Material(
                                clipBehavior: Clip.antiAlias,
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(
                                        Tween<double>(begin: 25, end: 30)
                                            .animate(_controller)
                                            .value)),
                                child: CachedNetworkImage(
                                  imageUrl: widget.topImage,
                                  fit: BoxFit.cover,
                                  width: _displaySize.width,
                                  height: 250,
                                ),
                              ),
                            )
                          : Container(),
                      Positioned(
                        bottom: Tween<double>(
                                begin: -_sheetHeight +
                                    MediaQuery.of(context).padding.bottom,
                                end: 0)
                            .animate(_controller)
                            .value,
                        height: _sheetHeight,
                        width: _displaySize.width,
                        child: Material(
                          key: _childKey,
                          color: ColorTween(
                                  begin: Colors.indigo, end: Colors.white)
                              .animate(CurvedAnimation(
                                  parent: _controller,
                                  curve: Interval(.7, 1.0,
                                      curve: Curves.easeInOut)))
                              .value,
                          clipBehavior: Clip.antiAlias,
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(
                                  Tween<double>(begin: 25, end: 30)
                                      .animate(_controller)
                                      .value)),
                          child: FadeTransition(
                              opacity: CurvedAnimation(
                                  parent: _controller,
                                  curve: Interval(.7, 1.0,
                                      curve: Curves.easeInOut)),
                              child: SingleChildScrollView(
                                  physics: _scrollingEnabled
                                      ? AlwaysScrollableScrollPhysics()
                                      : NeverScrollableScrollPhysics(),
                                  controller: _scrollController,
                                  child: child)),
                        ),
                      )
                    ],
                  ),
                );
              },
              child: widget.child,
            ),
          ),
        ),
      ],
    );
  }
}
