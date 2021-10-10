import 'package:flutter/material.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/provider/theme_manager.dart';

import 'margin.dart';

class PushNotification {
  BuildContext context;
  late OverlayEntry _overlayEntry;

  PushNotification(this.context);

  static PushNotification of(BuildContext context) {
    return PushNotification(context);
  }

  Future<void> show(NotificationContent content) async {
    print(content);
    _overlayEntry = OverlayEntry(builder: (context) {
      return PushWidget(content, () {
        _overlayEntry.remove();
      });
    });

    Overlay.of(context)!.insert(_overlayEntry);
  }
}

class PushWidget extends StatefulWidget {
  NotificationContent content;
  VoidCallback callback;
  PushWidget(this.content, this.callback);

  @override
  _PushWidgetState createState() => _PushWidgetState();
}

class _PushWidgetState extends State<PushWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late MediaQueryData _mq;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 750));
    _startAnim();

    super.initState();
  }

  Future<void> _startAnim() async {
    await _controller.forward();
    await Future.delayed(Duration(seconds: 2));
    await _controller.reverse();
    widget.callback();
  }

  @override
  Widget build(BuildContext context) {
    _mq = MediaQuery.of(context);
    ThemeData _theme = Theme.of(context);

    Color background =
        widget.content.isWarning ? _theme.errorColor : _theme.primaryColor;
    Color textColor = widget.content.isWarning
        ? _theme.colorScheme.onError
        : _theme.colorScheme.onPrimary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        Animation<double> curvedAnim = CurvedAnimation(
            parent: _controller, curve: Curves.fastLinearToSlowEaseIn);

        return Positioned(
            top: Tween<double>(begin: -100, end: _mq.padding.top)
                .animate(curvedAnim)
                .value,
            left: 0,
            right: 0,
            child: child!);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Material(
          borderRadius: BorderRadius.circular(6),
          color: background,
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  widget.content.icon,
                  color: textColor,
                ),
                XMargin(12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.content.title,
                        style: _theme.textTheme.headline6!
                            .copyWith(fontSize: 15, color: textColor),
                      ),
                      (widget.content.body == null ||
                              widget.content.body!.isEmpty)
                          ? Container(
                              width: 0,
                            )
                          : Text(widget.content.body!,
                              style: _theme.textTheme.bodyText1!
                                  .copyWith(color: textColor.withOpacity(.7))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NotificationContent {
  final String title;
  final String? body;
  final IconData icon;
  final bool isWarning;

  NotificationContent(
      {required this.title,
      this.body,
      this.icon = Icons.notification_important,
      this.isWarning = false});

  static NotificationContent fromMessage(Map<String, dynamic> map) {
    Map<String, dynamic> tempMap;

    print(map);

    tempMap = Map.from(map['aps']['alert']);

    print(tempMap);

    return NotificationContent(title: tempMap['title'], body: tempMap['body']);
  }

  @override
  String toString() {
    return "Title: $title, Body: $body";
  }
}
