import 'package:flutter/material.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:styled_text/styled_text.dart';
import 'package:url_launcher/url_launcher.dart';

class FormattedText extends StatelessWidget {
  final String text;
  final int? maxLines;
  final TextOverflow overflow;
  final TextAlign textAlign;
  final TextStyle? style;

  const FormattedText(this.text,
      {Key? key,
      this.maxLines,
      this.overflow = TextOverflow.clip,
      this.textAlign = TextAlign.start,
      this.style})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StyledText(
        text: text,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
        tags: {
          "b": StyledTextTag(style: TextStyle(fontWeight: FontWeight.bold)),
          "a": StyledTextActionTag((val, map) async {
            print(map);
            String? url = map["href"];

            if (url != null && await canLaunch(url)) {
              await launch(url);
            }
          },
              style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: context.theme.colorScheme.secondary)),
        });
  }
}
