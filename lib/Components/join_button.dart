import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:one_d_m/provider/theme_manager.dart';

class JoinButton extends StatefulWidget {
  final Function(bool join)? joinOrLeave;
  final Color? subscribedColor, notSubscribedColor;
  final String subscribedString, notSubscribedString;
  final bool? subscribed;

  const JoinButton(
      {Key? key,
      this.joinOrLeave,
      this.subscribedColor,
      this.notSubscribedColor,
      this.subscribedString = "Beitreten",
      this.notSubscribedString = "Verlassen",
      this.subscribed = false})
      : super(key: key);

  @override
  _JoinButtonState createState() => _JoinButtonState();
}

class _JoinButtonState extends State<JoinButton> {
  bool _loading = false;
  late Color subscribedColor, notSubscribedColor;

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);

    subscribedColor = widget.subscribedColor ?? _theme.colorScheme.primary;
    notSubscribedColor =
        widget.notSubscribedColor ?? _theme.colorScheme.secondary;

    Color background =
        widget.subscribed! ? subscribedColor : notSubscribedColor;
    String title = widget.subscribed!
        ? widget.notSubscribedString
        : widget.subscribedString;

    if (widget.joinOrLeave == null) {
      background = Colors.grey[300]!;
      title = "Laden...";
    }

    Color textColor =
        (widget.subscribedColor == null && widget.notSubscribedColor == null)
            ? (widget.subscribed!
                ? _theme.colorScheme.onPrimary
                : _theme.colorScheme.onSecondary)
            : background.textColor;

    return MaterialButton(
      color: background,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      elevation: 0,
      disabledColor: Colors.grey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: AnimatedSize(
        duration: Duration(milliseconds: 125),
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 250),
          child: _loading
              ? LoadingIndicator(size: 18, color: textColor)
              : Text(
                  title,
                  style: _theme.textTheme.bodyText2!.copyWith(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
        ),
      ),
      onPressed: widget.joinOrLeave != null
          ? () async {
              setState(() {
                _loading = true;
              });

              await widget.joinOrLeave!(!widget.subscribed!);

              setState(() {
                _loading = false;
              });
            }
          : null,
    );
  }
}
