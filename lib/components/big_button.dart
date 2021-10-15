import 'package:flutter/material.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:one_d_m/helper/constants.dart';
import 'loading_indicator.dart';

class BigButton extends StatelessWidget {
  final bool loading;
  final void Function()? onPressed;
  final Color? color;
  final String label;
  final double? fontSize;

  const BigButton(
      {Key? key,
      required this.label,
      required this.onPressed,
      this.fontSize,
      this.loading = false,
      this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = context.theme;
    Color _color = color ?? _theme.primaryColor,
        _textColor = color != null
            ? _theme.correctColorFor(_color)
            : _theme.colorScheme.onPrimary;

    return MaterialButton(
      onPressed: onPressed ?? () {},
      elevation: 0,
      highlightElevation: 7,
      color: _color,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Constants.radius)),
      child: Container(
        height: 50,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSize(
              duration: Duration(milliseconds: 1000),
              curve: Curves.fastLinearToSlowEaseIn,
              child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 1000),
                  switchInCurve: Curves.fastLinearToSlowEaseIn,
                  switchOutCurve: Curves.fastLinearToSlowEaseIn,
                  child: loading
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
                          child: LoadingIndicator(
                              color: _textColor, size: 14, strokeWidth: 2),
                        )
                      : Container()),
            ),
            Text(
              label,
              style: _theme.textTheme.bodyText1!
                  .copyWith(color: _textColor, fontSize: fontSize),
            ),
          ],
        ),
      ),
    );
  }
}
