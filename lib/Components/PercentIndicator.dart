import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';

class PercentIndicator extends StatefulWidget {
  int currentValue, targetValue;
  String description;
  Function onTap;

  PercentIndicator(
      {this.currentValue,
      this.targetValue,
      this.description,
      this.onTap,});

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 50,
            child: Text(
              widget.description,
              style: Theme.of(context).textTheme.body1,
            ),
          ),
          Expanded(
            child: Container(
              height: 13,
              child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                                          child: LinearProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(ColorTheme.percentSlider),
                        value: _valueTween.evaluate(_controller),
                        backgroundColor: ColorTheme.lightGrey,
                      ),
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
