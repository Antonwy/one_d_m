import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/Helper.dart';

class CampaignBottomSheet {
  final BuildContext context;
  final ValueNotifier<bool> _notifier = ValueNotifier(true);
  final Duration duration;
  final Curve curve;
  final String topImage;

  CampaignBottomSheet(this.context,
      {this.duration = const Duration(milliseconds: 500),
      this.curve = Curves.easeInOut,
      this.topImage});

  static CampaignBottomSheet of(BuildContext context) {
    return CampaignBottomSheet(context);
  }

  CampaignBottomSheet withTopImage(String imgUrl) {
    return CampaignBottomSheet(this.context,
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

  double _sheetDragOffset = 0.0;

  AnimationController _controller;

  ScrollController _scrollController = ScrollController();

  bool _isOpen = false, _closing = false, _reachedTop = false;

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
    print(_sheetDragOffset);
    if (_sheetDragOffset >= 0) {
      if (_sheetDragOffset == 0 && details.delta.dy > 0) {
        _controller.value -=
            details.primaryDelta / (_childHeight ?? details.primaryDelta);
        return;
      }

      setState(() {
        _sheetDragOffset -= details.delta.dy;
        _sheetDragOffset = _sheetDragOffset.clamp(0.0, 225.0);
      });
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_sheetDragOffset == 0.0) {
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
  }

  void _changeReachedTop(bool tf) {
    _reachedTop = tf;
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
                  progress: CurvedAnimation(
                          parent: _controller,
                          curve: _isOpen ? Curves.easeOut : widget.curve,
                          reverseCurve: Curves.easeOut)
                      .value,
                  offset: MediaQuery.of(context).padding.bottom,
                  sheetDragOffset: _sheetDragOffset,
                ),
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
                      color: ColorTween(begin: Colors.indigo, end: Colors.white)
                          .animate(CurvedAnimation(
                              parent: _controller, curve: Interval(.7, 1.0)))
                          .value,
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
                          child: NotificationListener<ScrollNotification>(
                              child: SingleChildScrollView(
                                physics: _sheetDragOffset == 225.0
                                    ? AlwaysScrollableScrollPhysics()
                                    : NeverScrollableScrollPhysics(),
                                child: child,
                                controller: _scrollController,
                              ),
                              onNotification: (notification) {
                                if (notification is ScrollUpdateNotification) {
                                  if (notification.metrics.pixels == 0.0 &&
                                      _sheetDragOffset == 225.0) {
                                    print("NOW");
                                    setState(() {
                                      _sheetDragOffset = 224.0;
                                    });
                                  }
                                }
                                return false;
                              })),
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
  _DialogLayout({
    this.progress,
    this.offset,
    this.sheetDragOffset,
  });

  final double progress;
  final double offset;
  final double sheetDragOffset;

  Offset getPositionForSheet(Size size, Size childSize) {
    Offset o = Offset(
        0.0,
        size.height -
            offset -
            (size.height * .7 - offset) * progress -
            sheetDragOffset);
    return o;
  }

  Offset getPositionForImage(Size size, Size childSize) {
    return Offset(
        0.0, size.height - offset - (size.height * .7 - offset) * progress);
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
          getPositionForImage(size, sheetSize).translate(
              0,
              -(imageSize.height - 25) *
                  Interval(.7, 1.0).transform(progress)));
    }
  }

  @override
  bool shouldRelayout(_DialogLayout oldDelegate) {
    return progress != oldDelegate.progress ||
        sheetDragOffset != oldDelegate.sheetDragOffset;
  }
}
