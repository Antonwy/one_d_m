import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';

class ReplaceText extends StatelessWidget {
  final String text, value;
  final TextStyle style, boldStyle;

  const ReplaceText(
      {Key key,
      @required this.text,
      @required this.value,
      this.style,
      this.boldStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    if (text.contains("**")) {
      List<String> splitted = text.split("**");
      return RichText(
          text: TextSpan(
              style: style ?? _theme.textTheme.textOnContrast.bodyText2,
              children: [
            TextSpan(
              text: splitted[0],
            ),
            TextSpan(
                text: value,
                style: boldStyle ?? TextStyle(fontWeight: FontWeight.w800)),
            TextSpan(
              text: splitted.length >= 2 ? splitted[1] : "",
            ),
          ]));
    }

    return Text(
      text,
      style: style ?? _theme.textTheme.textOnContrast.bodyText1,
    );
  }
}
