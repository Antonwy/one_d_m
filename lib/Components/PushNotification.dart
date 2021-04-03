import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/margin.dart';

class PushNotification {
  BuildContext context;
  OverlayEntry _overlayEntry;

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

    Overlay.of(context).insert(_overlayEntry);
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
  AnimationController _controller;
  MediaQueryData _mq;

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
    ThemeManager _theme = ThemeManager.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        Animation curvedAnim = CurvedAnimation(
            parent: _controller, curve: Curves.fastLinearToSlowEaseIn);

        return Positioned(
            top: Tween<double>(begin: -100, end: _mq.padding.top)
                .animate(curvedAnim)
                .value,
            left: 0,
            right: 0,
            child: Transform.scale(
                scale:
                    Tween<double>(begin: 0.8, end: 1).animate(curvedAnim).value,
                child: child));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Material(
          borderRadius: BorderRadius.circular(Constants.radius),
          elevation: 1,
          color: _theme.colors.dark,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  widget.content?.icon ?? Icons.notification_important,
                  color: _theme.colors.textOnDark,
                ),
                XMargin(12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.content?.title,
                        style: Theme.of(context).textTheme.headline6.copyWith(
                            color: _theme.colors.textOnDark, fontSize: 15),
                      ),
                      (widget.content.body == null ||
                              widget.content.body.isEmpty)
                          ? Container(
                              width: 0,
                            )
                          : Text(
                              widget.content.body,
                              style: _theme.textTheme.textOnDark
                                  .withOpacity(.7)
                                  .bodyText1,
                            ),
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
  String title, body;
  IconData icon;

  NotificationContent(
      {this.title, this.body, this.icon = Icons.notification_important});

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
