import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/provider/theme_manager.dart';

class JoinButton extends StatefulWidget {
  final Function(bool join) joinOrLeave;
  final Color subscribedColor, notSubscribedColor;
  final String subscribedString, notSubscribedString;
  final bool subscribed;

  const JoinButton(
      {Key key,
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
  Color subscribedColor, notSubscribedColor;

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    subscribedColor = widget.subscribedColor ?? _theme.colors.contrast;
    notSubscribedColor = widget.notSubscribedColor ?? _theme.colors.dark;
    Color background = widget.subscribed ? subscribedColor : notSubscribedColor;
    String title = widget.subscribed
        ? widget.notSubscribedString
        : widget.subscribedString;

    if (widget.joinOrLeave == null) {
      background = Colors.grey[300];
      title = "Laden...";
    }

    return MaterialButton(
      color: background,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: AnimatedSize(
        duration: Duration(milliseconds: 250),
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 250),
          child: _loading
              ? Container(
                  width: 18,
                  height: 18,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3.0,
                      valueColor: AlwaysStoppedAnimation(
                          _theme.correctColorFor(background)),
                    ),
                  ))
              : Text(
                  title,
                  style: _theme.textTheme
                      .correctColorFor(background)
                      .bodyText2
                      .copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                ),
        ),
      ),
      onPressed: widget.joinOrLeave != null
          ? () async {
              setState(() {
                _loading = true;
              });

              await widget.joinOrLeave(!widget.subscribed);

              setState(() {
                _loading = false;
              });
            }
          : null,
    );
  }
}
