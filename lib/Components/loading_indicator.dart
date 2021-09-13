import 'package:flutter/material.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/provider/theme_manager.dart';

class LoadingIndicator extends StatelessWidget {
  final String message;
  final double strokeWidth, size;
  final Color color;
  const LoadingIndicator(
      {this.message, this.strokeWidth = 4.0, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    Widget indicator = CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation(
            color ?? ThemeManager.of(context).colors.dark));

    if (size != null)
      indicator = Container(width: size, height: size, child: indicator);

    if (message != null)
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [indicator, YMargin(12), Text(message)],
      );

    return indicator;
  }
}
