import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _JoinButtonState extends State<JoinButton>
    with SingleTickerProviderStateMixin {
  bool _loading = false, _buttonDown = false;
  late Color subscribedColor, notSubscribedColor;
  late AnimationController _controller;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 180));

    super.initState();
  }

  Future<void> pulse() async {
    await _controller.forward();
    HapticFeedback.mediumImpact();
    await _controller.reverse();
  }

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

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
            scale: Tween<double>(begin: 1.0, end: 1.3).evaluate(
                CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
            child: child);
      },
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(6),
        clipBehavior: Clip.antiAlias,
        elevation: _buttonDown ? 10 : 0,
        child: InkWell(
          onTapDown: (val) => setState(() {
            _buttonDown = true;
          }),
          onTapCancel: () => setState(() {
            _buttonDown = false;
          }),
          onTap: widget.joinOrLeave != null
              ? () async {
                  setState(() {
                    _loading = true;
                    _buttonDown = false;
                  });

                  await widget.joinOrLeave!(!widget.subscribed!);

                  pulse();

                  setState(() {
                    _loading = false;
                  });
                }
              : null,
          child: Container(
            width: 80,
            height: 35,
            child: Stack(
              children: [
                Center(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 360),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeOut,
                    transitionBuilder: (child, animation) {
                      double dir = -2;

                      if (child.key.toString() == ValueKey(false).toString()) {
                        dir = 2;
                      }

                      return SlideTransition(
                        child: ScaleTransition(
                            scale: Tween<double>(begin: .75, end: 1)
                                .animate(animation),
                            child: FadeTransition(
                                opacity: Tween<double>(begin: 0, end: 1)
                                    .animate(animation),
                                child: child)),
                        position: Tween<Offset>(
                                begin: Offset(0, dir), end: Offset.zero)
                            .animate(animation),
                      );
                    },
                    child: Text(
                      title,
                      key: ValueKey(widget.subscribed),
                      style: _theme.textTheme.bodyText2!.copyWith(
                          color: textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 250),
                      child: _loading
                          ? Container(
                              height: 3,
                              child: LinearProgressIndicator(
                                color: textColor,
                                backgroundColor: Colors.transparent,
                              ),
                            )
                          : SizedBox.shrink(),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
