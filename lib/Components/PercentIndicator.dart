import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';

class PercentIndicator extends StatefulWidget {
  int currentValue, targetValue;
  String description;
  Function onTap;

  PercentIndicator({
    this.currentValue,
    this.targetValue,
    this.description,
    this.onTap,
  });

  @override
  _PercentIndicatorState createState() => _PercentIndicatorState();
}

class _PercentIndicatorState extends State<PercentIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Tween<double> _valueTween;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));

    _valueTween = Tween<double>(begin: 0, end: animatedValue);

    _controller.forward();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PercentIndicator oldWidget) {
    if (widget.currentValue != oldWidget.currentValue) {
      double beginValue = this._valueTween.evaluate(this._controller);

      this._valueTween = Tween<double>(
        begin: beginValue,
        end: animatedValue,
      );

      this._controller
        ..value = 0
        ..forward();
    }

    super.didUpdateWidget(oldWidget);
  }

  double get animatedValue =>
      widget.currentValue == 0 ? 0 : widget.currentValue / widget.targetValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Stack(
                      children: <Widget>[
                        Center(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "${widget.currentValue}/${widget.targetValue} DV",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        )),
                        Positioned.fill(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation(ColorTheme.white),
                            value: _valueTween.evaluate(_controller),
                            backgroundColor: Colors.white24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
      ],
    );
  }
}
