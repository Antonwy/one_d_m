import 'package:flutter/material.dart';
import 'package:one_d_m/components/margin.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double? strokeWidth, size, progress;
  final Color? color;
  const LoadingIndicator(
      {this.message,
      this.strokeWidth = 4.0,
      this.size,
      this.color,
      this.progress});

  @override
  Widget build(BuildContext context) {
    Widget indicator = CircularProgressIndicator(
        strokeWidth: strokeWidth!,
        value: progress,
        valueColor: AlwaysStoppedAnimation(
          color ?? Theme.of(context).primaryColor,
        ));

    if (size != null)
      indicator = Container(width: size, height: size, child: indicator);

    if (message != null)
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [indicator, YMargin(12), Text(message!)],
      );

    return indicator;
  }
}
