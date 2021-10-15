import 'package:flutter/material.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';

class AnimatedElevatedButton extends StatelessWidget {
  final Widget? icon;
  final String label;
  final void Function()? onPressed;
  final Color? backgroundColor;
  final MaterialTapTargetSize? tapTargetSize;
  final bool loading;

  const AnimatedElevatedButton(
      {Key? key,
      this.icon,
      required this.label,
      required this.onPressed,
      this.backgroundColor,
      this.loading = false,
      this.tapTargetSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [Container()];

    if (icon != null)
      list = [
        SizedBox(width: 18, height: 18, child: FittedBox(child: icon!)),
        XMargin(6)
      ];

    if (loading)
      list = [
        LoadingIndicator(
          size: 14,
          strokeWidth: 2,
          color:
              backgroundColor?.textColor ?? context.theme.colorScheme.onPrimary,
        ),
        XMargin(10)
      ];

    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: backgroundColor ?? context.theme.colorScheme.primary,
            onSurface: (backgroundColor ?? context.theme.colorScheme.primary),
            tapTargetSize: tapTargetSize),
        onPressed: loading ? () {} : onPressed,
        child: Row(
          children: [
            ...list,
            Text(label),
          ],
        ));
  }
}
