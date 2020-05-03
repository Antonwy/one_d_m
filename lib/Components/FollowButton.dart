import 'dart:math';

import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';

class FollowButton extends StatelessWidget {
  VoidCallback onPressed;
  bool followed;
  final Duration _duration = Duration(milliseconds: 125);

  FollowButton({this.onPressed, this.followed});

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: CircleBorder(),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: InkWell(
        onTap: onPressed ?? () {},
        child: AnimatedContainer(
          width: 56,
          height: 56,
          duration: _duration,
          color: followed ? ColorTheme.red : Colors.white,
          child: TweenAnimationBuilder(
              duration: _duration,
              tween: Tween<double>(
                  begin: 0, end: followed ? degreesToRads(45) : 0.0),
              builder: (context, value, child) =>
                  Transform.rotate(angle: value, child: child),
              child: TweenAnimationBuilder(
                  tween: ColorTween(
                      begin: Colors.indigo,
                      end: followed ? Colors.white : ColorTheme.darkBlue),
                  duration: _duration,
                  builder: (context, color, child) =>
                      Icon(Icons.add, color: color))),
        ),
      ),
    );
  }

  double degreesToRads(double deg) {
    return (deg * pi) / 180.0;
  }
}
