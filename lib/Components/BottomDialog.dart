import 'package:flutter/material.dart';

class BottomDialog {
  BuildContext context;
  ValueNotifier<bool> _notifier = ValueNotifier(true);
  Duration duration;
  Curve curve;

  BottomDialog(this.context,
      {this.duration = const Duration(milliseconds: 250),
      this.curve = Curves.easeInOut});

  Future<void> show(Widget widget) async {
    await Navigator.push(
        context,
        PageRouteBuilder(
            opaque: false,
            transitionDuration: Duration.zero,
            pageBuilder: (c, animOne, animTwo) => _Dialog(widget,
                open: _notifier, duration: duration, curve: curve)));
  }

  void close() {
    _notifier.value = false;
  }
}

class _Dialog extends StatefulWidget {
  Widget child;
  ValueNotifier<bool> open;
  Duration duration;
  Curve curve;

  _Dialog(this.child, {this.open, this.duration, this.curve});

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
    _controller.reverse().then((c) {
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
            return ClipRRect(
              child: CustomSingleChildLayout(
                delegate: _DialogLayout(CurvedAnimation(
                  parent: _controller,
                  curve: _isOpen ? Curves.easeOut : widget.curve,
                ).value),
                child: GestureDetector(
                  onVerticalDragUpdate: _handleDragUpdate,
                  onVerticalDragEnd: _handleDragEnd,
                  child: Container(
                    key: _childKey,
                    child: child,
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
      minHeight: 0,
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
