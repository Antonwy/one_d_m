import 'package:flutter/material.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/provider/theme_manager.dart';

class WarningIcon extends StatelessWidget {
  final double size;
  final String? message;

  const WarningIcon({this.size = 18, this.message});

  @override
  Widget build(BuildContext context) {
    Widget icon = Container(
      height: size * 2,
      width: size * 2,
      child: Material(
        color: Colors.red.withOpacity(.15),
        shape: CircleBorder(),
        child:
            Center(child: Icon(Icons.warning, color: Colors.red, size: size)),
      ),
    );

    return message != null
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              YMargin(12),
              Text(message!,
                  style: ThemeManager.of(context).textTheme.dark.caption)
            ],
          )
        : icon;
  }
}
