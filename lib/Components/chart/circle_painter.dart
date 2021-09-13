import "package:flutter/material.dart";
//import 'package:flutter_canvas/size_const.dart';
import 'dart:math';

import 'circle.dart';

const BLUE_NORMAL = Color(0xff54c5f8);
const GREEN_NORMAL = Color(0xff6bde54);
const BLUE_DARK2 = Color(0xff01579b);
const BLUE_DARK1 = Color(0xff29b6f6);
const RED_DARK1 = Color(0xfff26388);
const RED_DARK2 = Color(0xfff782a0);
const RED_DARK3 = Color(0xfffb8ba8);
const RED_DARK4 = Color(0xfffb89a6);
const RED_DARK5 = Color(0xfffd86a5);
const YELLOW_NORMAL = Color(0xfffcce89);
const List<Point> POINT = [Point(100, 100)];

class CirclePainter extends CustomPainter {
  final double width;
  final double height;
  List<Color> colors;

  CirclePainter(this.width, this.height, {this.startAngle, this.colors});

  final double startAngle;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..style = PaintingStyle.fill
      ..color = BLUE_NORMAL
      ..strokeWidth = 1.0
      ..isAntiAlias = true;
    paint.color = Colors.grey[900];
    paint.color = RED_DARK1;
    paint.strokeWidth = 20;
    paint.style = PaintingStyle.stroke;
    var center = Offset(
      getAxisX((width / 2) - 50, width),
      getAxisY((height / 2) - 50, height),
    );
    var radius = getAxisBoth(200, width, height);
    _drawArcGroup(
      canvas,
      center: center,
      radius: radius,
      sources: [
        70,
        25,
        5,
      ],
      colors: colors,
      paintWidth: 8.0,
      startAngle: 1.3 * startAngle / radius,
      hasEnd: true,
      hasCurrent: false,
      curPaintWidth: 45.0,
      curIndex: 1,
    );
    canvas.save();
    canvas.restore();
  }

  void _drawArcGroup(Canvas canvas,
      {Offset center,
      double radius,
      List<double> sources,
      List<Color> colors,
      double startAngle = 0.0,
      double paintWidth = 10.0,
      bool hasEnd = false,
      hasCurrent = false,
      int curIndex = 0,
      curPaintWidth = 12.0}) {
    assert(sources != null && sources.length > 0);
    assert(colors != null && colors.length > 0);
    var paint = Paint()
      ..style = PaintingStyle.fill
      ..color = BLUE_NORMAL
      ..strokeWidth = paintWidth
      ..isAntiAlias = true;
    double total = 0;
    for (double d in sources) {
      total += d;
    }
    assert(total > 0.0);
    List<double> radians = [];
    for (double d in sources) {
      double radian = d * 2 * pi / total;
      radians.add(radian);
    }
    var startA = startAngle;
    paint.style = PaintingStyle.stroke;
    var curStartAngle = 0.0;
    for (int i = 0; i < radians.length; i++) {
      var rd = radians[i];
      if (hasCurrent && curIndex == i) {
        curStartAngle = startA;
        startA += rd;
        continue;
      }
      paint.color = colors[i % colors.length];
      paint.strokeWidth = paintWidth;
      _drawArcWithCenter(canvas, paint,
          center: center, radius: radius, startRadian: startA, sweepRadian: rd);
      startA += rd;
    }
    if (hasEnd) {
      startA = startAngle;
      paint.strokeWidth = paintWidth;
      for (int i = 0; i < radians.length; i++) {
        var rd = radians[i];
        if (hasCurrent && curIndex == i) {
          startA += rd;
          continue;
        }
        paint.color = colors[i % colors.length];
        paint.strokeWidth = paintWidth;
        _drawArcTwoPoint(canvas, paint,
            center: center,
            radius: radius,
            startRadian: startA,
            sweepRadian: rd,
            hasEndArc: true);
        startA += rd;
      }
    }

    if (hasCurrent) {
      paint.color = colors[curIndex % colors.length];
      paint.strokeWidth = curPaintWidth;
      paint.style = PaintingStyle.stroke;
      _drawArcWithCenter(canvas, paint,
          center: center,
          radius: radius,
          startRadian: curStartAngle,
          sweepRadian: radians[curIndex]);
    }
    if (hasCurrent && hasEnd) {
      var rd = radians[curIndex % radians.length];
      paint.color = colors[curIndex % colors.length];
      paint.strokeWidth = curPaintWidth;
      paint.style = PaintingStyle.fill;
      _drawArcTwoPoint(canvas, paint,
          center: center,
          radius: radius,
          startRadian: curStartAngle,
          sweepRadian: rd,
          hasEndArc: true,
          hasStartArc: true);
    }
  }

  void _drawArcWithCenter(
    Canvas canvas,
    Paint paint, {
    Offset center,
    double radius,
    startRadian = 0.0,
    sweepRadian = pi,
  }) {
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startRadian,
      sweepRadian,
      false,
      paint,
    );
  }

  void _drawArcTwoPoint(Canvas canvas, Paint paint,
      {Offset center,
      double radius,
      startRadian = 0.0,
      sweepRadian = pi,
      hasStartArc = false,
      hasEndArc = false}) {
    var smallR = paint.strokeWidth / 2;
    paint.strokeWidth = smallR;
    if (hasStartArc) {
      var startCenter = LineCircle.radianPoint(
          Point(center.dx, center.dy), radius, startRadian);
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(startCenter.x, startCenter.y), smallR, paint);
    }
    if (hasEndArc) {
      var endCenter = LineCircle.radianPoint(
          Point(center.dx, center.dy), radius, startRadian + sweepRadian);
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(endCenter.x, endCenter.y), smallR, paint);
    }
  }

  //@param w is the design w;
  double getAxisX(double w, double width) {
    return (w * width) / Size(3000.0, 3000.0).width;
  }

// the y direction
  double getAxisY(
    double h,
    double height,
  ) {
    return (h * height) / Size(3000.0, 3000.0).height;
  }

  // diagonal direction value with design size s.
  double getAxisBoth(double s, double width, double height) {
    return s *
        sqrt((width * width + height * height) /
            (Size(3000.0, 3000.0).width * Size(3000.0, 3000.0).width +
                Size(3000.0, 3000.0).height * Size(3000.0, 3000.0).height));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
