import 'package:flutter/material.dart';

class BottomDialog {
  BuildContext context;
  Widget widget;

  BottomDialog({this.context, this.widget});

  void show() {
    Navigator.push(
        context,
        PageRouteBuilder(
            opaque: false,
            transitionDuration: Duration.zero,
            pageBuilder: (c, animOne, animTwo) => _Dialog(widget)));
  }
}

class _Dialog extends StatefulWidget {
  Widget child;

  _Dialog(this.child);

  @override
  __DialogState createState() => __DialogState();
}

class __DialogState extends State<_Dialog> with SingleTickerProviderStateMixin {
  Size _displaySize;

  AnimationController _controller;
  Duration _duration = Duration(milliseconds: 250);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
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
        _closeWidget();
      }
    } else if (_controller.value < .5) {
      if (_controller.value > 0.0) _controller.fling(velocity: -1.0);
      _closeWidget();
    } else {
      _controller.forward();
    }
  }

  _closeWidget() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    _displaySize = MediaQuery.of(context).size;
    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            _controller.reverse().then((c) {
              _closeWidget();
            });
          },
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
            return ClipRRect(
              child: CustomSingleChildLayout(
                delegate: _DialogLayout(_controller.value),
                child: GestureDetector(
                  onVerticalDragUpdate: _handleDragUpdate,
                  onVerticalDragEnd: _handleDragEnd,
                  child: Container(
                    key: _childKey,
                    child: widget.child,
                  ),
                ),
              ),
            );
          },
          child: widget.child,
        ),
      ],
    );
  }
}

class _DialogLayout extends SingleChildLayoutDelegate {
  _DialogLayout(this.progress);

  final double progress;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: 0.0,
      maxHeight: constraints.maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - childSize.height * progress);
  }

  @override
  bool shouldRelayout(_DialogLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
