import 'package:flutter/material.dart';

class PercentIndicator extends StatefulWidget {
  int currentValue, targetValue;
  String description;
  Color color;
  Function onTap;

  PercentIndicator(
      {this.currentValue,
      this.targetValue,
      this.description,
      this.onTap,
      this.color = Colors.indigo});

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
        Container(
          width: 100,
          height: 100,
          child: Material(
            shape: CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.all(1.5),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    AnimatedBuilder(
                        animation: _controller,
                        builder: (context, snapshot) {
                          return CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(widget.color),
                            value: _valueTween.evaluate(_controller),
                            backgroundColor: Colors.grey[300],
                          );
                        }),
                    Center(
                        child: Container(
                            width: 90,
                            padding: EdgeInsets.all(5),
                            child: Text(
                              "${widget.currentValue}/${widget.targetValue} DC",
                              textAlign: TextAlign.center,
                            )))
                  ],
                ),
              ),
            ),
          ),
        ),
        Text(widget.description)
      ],
    );
  }
}
