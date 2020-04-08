import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NavBarDialog {
  final BuildContext context;
  final ValueNotifier<bool> _notifier = ValueNotifier(true);
  final Duration duration;
  final Curve curve;
  final String topImage;

  NavBarDialog(this.context,
      {this.duration = const Duration(milliseconds: 500),
      this.curve = Curves.easeInOut,
      this.topImage});

  static NavBarDialog of(BuildContext context) {
    return NavBarDialog(context);
  }

  NavBarDialog withTopImage(String imgUrl) {
    return NavBarDialog(this.context,
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

  bool _isOpen = false;

  @override
  void initState() {
    super.initState();

    widget.open.addListener(() {
      if (!widget.open.value) close();
    });

    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.forward().whenComplete(() {
      _isOpen = true;
    });
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

  void _handleDragUpdate(DragUpdateDetails details) {
    _controller.value -=
        details.primaryDelta / (_childHeight ?? details.primaryDelta);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (details.velocity.pixelsPerSecond.dy > 700) {
      final double flingVelocity =
          -details.velocity.pixelsPerSecond.dy / _childHeight;
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
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return GestureDetector(
              onVerticalDragUpdate: _handleDragUpdate,
              onVerticalDragEnd: _handleDragEnd,
              child: CustomMultiChildLayout(
                delegate: _DialogLayout(
                    CurvedAnimation(
                            parent: _controller,
                            curve: _isOpen ? Curves.easeOut : widget.curve,
                            reverseCurve: Curves.easeOut)
                        .value,
                    MediaQuery.of(context).padding.bottom),
                children: <Widget>[
                  LayoutId(
                    id: 1,
                    child: widget.topImage != null
                        ? Material(
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
                          )
                        : Container(),
                  ),
                  LayoutId(
                    id: 2,
                    child: Material(
                      key: _childKey,
                      color: Colors.indigo,
                      clipBehavior: Clip.antiAlias,
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(Tween<double>(begin: 25, end: 30)
                              .animate(_controller)
                              .value)),
                      child: FadeTransition(
                          opacity: CurvedAnimation(
                              parent: _controller,
                              curve:
                                  Interval(.7, 1.0, curve: Curves.easeInOut)),
                          child: child),
                    ),
                  )
                ],
              ),
            );
          },
          child: widget.child,
        ),
      ],
    );
  }
}

class _DialogLayout extends MultiChildLayoutDelegate {
  _DialogLayout(this.progress, this.offset);

  final double progress;
  final double offset;

  Offset getPositionForSheet(Size size, Size childSize) {
    return Offset(
        0.0, size.height - offset - (childSize.height - offset) * progress);
  }

  @override
  void performLayout(Size size) {
    Size imageSize, sheetSize;

    if (hasChild(2)) {
      sheetSize = layoutChild(
          2, BoxConstraints(maxHeight: size.height, maxWidth: size.width));
      positionChild(2, getPositionForSheet(size, sheetSize));
    }

    if (hasChild(1)) {
      imageSize = layoutChild(
          1, BoxConstraints(maxHeight: size.height, maxWidth: size.width));
      positionChild(
          1,
          getPositionForSheet(size, sheetSize).translate(
              0,
              -(imageSize.height - 25) *
                  Interval(.7, 1.0).transform(progress)));
    }
  }

  @override
  bool shouldRelayout(_DialogLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
