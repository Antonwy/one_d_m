import 'package:flutter/material.dart';

class RectRevealRoute extends PageRouteBuilder {
  final Widget page;
  final Offset offset;
  final Size startSize;
  final double startRadius;
  final Color color;
  Color startColor;
  final Duration duration;

  RectRevealRoute(
      {@required this.page,
      @required this.startSize,
      this.startRadius = 0.0,
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
                      painter: RectRevealPainter(
                          anim: CurvedAnimation(
                              parent: animation, curve: Interval(0.0, .7, curve: Curves.fastOutSlowIn)),
                          offset: offset,
                          color: color,
                          startRadius: startRadius,
                          startColor: startColor,
                          startSize: startSize),
                    );
                  },
                )) {
    if (startColor == null) this.startColor = color;
  }
}

class RectRevealPainter extends CustomPainter {
  Animation<double> anim;
  Offset offset;
  Size startSize;
  double startRadius;
  Color color;
  Color startColor;

  RectRevealPainter(
      {this.anim,
      this.offset,
      this.color,
      this.startColor,
      this.startSize,
      this.startRadius});

  Paint _rectPaint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Tween<Offset>(
                      begin: offset,
                      end: Offset(size.width / 2, size.height / 2))
                  .lerp(getValue().value),
              width: Tween<double>(begin: startSize.width, end: size.width)
                  .lerp(getValue().value),
              height: Tween<double>(begin: startSize.height, end: size.height)
                  .lerp(getValue().value),
            ),
            Radius.lerp(Radius.circular(startRadius), Radius.circular(0),
                getValue().value)),
        _rectPaint
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
