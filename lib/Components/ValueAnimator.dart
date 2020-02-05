import 'package:flutter/material.dart';

class ValueAnimator extends StatefulWidget {
  dynamic value;
  Widget Function(dynamic) builder;
  Duration duration;
  Curve curve;
  TweenType tweenType;

  ValueAnimator(
      {Key key,
      @required this.value,
      @required this.builder,
      this.duration = const Duration(milliseconds: 500),
      this.curve = Curves.linear,
      this.tweenType = TweenType.VALUE})
      : super(key: key);

  @override
  _ValueAnimatorState createState() => _ValueAnimatorState();
}

class _ValueAnimatorState extends State<ValueAnimator>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _tween;

  dynamic _currVal, _oldVal;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    _currVal = widget.value;
    _oldVal = _currVal;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.duration = widget.duration;
    if (_currVal != widget.value) {
      setState(() {
        _oldVal = _tween.value;
        _currVal = widget.value;
      });

      _controller.reset();
      _controller.forward();
    }

    _tween = _getTween()
      ..addListener(() {
        setState(() {});
      });

    return widget.builder(_tween.value);
  }

  Animation _getTween() {
    switch (widget.tweenType) {
      case TweenType.VALUE:
        return Tween(begin: _oldVal, end: _currVal)
            .animate(CurvedAnimation(parent: _controller, curve: widget.curve));
      case TweenType.COLOR:
        return ColorTween(begin: _oldVal, end: _currVal)
            .animate(CurvedAnimation(parent: _controller, curve: widget.curve));
      case TweenType.INT:
        return IntTween(begin: _oldVal, end: _currVal)
            .animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    }
    return Tween<double>(begin: _oldVal, end: _currVal)
        .animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }
}

enum TweenType { COLOR, VALUE, INT }
