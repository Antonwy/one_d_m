import 'dart:math' as math;

import 'package:flutter/material.dart';

class CircularRevealRoute extends PageRouteBuilder {
  final Widget page;
  final Offset offset;
  final Color color;
  Color startColor;
  final Duration duration;

  CircularRevealRoute(
      {this.page,
      this.offset = const Offset(0, 0),
      this.color = Colors.red,
      this.startColor,
      this.duration = const Duration(milliseconds: 500)})
      : super(
            opaque: true,
            pageBuilder: (context, _, __) => page,
            transitionDuration: duration,
            transitionsBuilder: (context, Animation<double> animation,
                    Animation<double> secondaryAnimation, Widget child) =>
                LayoutBuilder(
                  builder: (context, constraints) {
                    return CustomPaint(
                      child: FadeTransition(
                        child: child,
                        opacity: CurvedAnimation(
                            parent: animation, curve: Interval(.3, 1.0)),
                      ),
                      painter: CircularRevealPainter(
                          anim: animation,
                          offset: offset,
                          color: color,
                          startColor: startColor),
                    );
                  },
                )) {
    if (startColor == null) this.startColor = color;
  }
}

class CircularRevealPainter extends CustomPainter {
  Animation<double> anim;
  Offset offset;
  Color color;
  Color startColor;

  CircularRevealPainter({this.anim, this.offset, this.color, this.startColor});

  Paint _circlePaint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
        offset,
        math.sqrt(size.width * size.width + size.height * size.height) *
            getValue().value,
        _circlePaint
          ..color =
              ColorTween(begin: startColor, end: color).lerp(getValue().value));
  }

  Animation<double> getValue() =>
      CurvedAnimation(parent: anim, curve: Curves.easeInOut);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
