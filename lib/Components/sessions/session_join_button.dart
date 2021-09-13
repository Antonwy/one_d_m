import 'package:flutter/material.dart';
import 'package:one_d_m/components/join_button.dart';
import 'package:one_d_m/provider/sessions_manager.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:provider/provider.dart';

class SessionJoinButton extends StatefulWidget {
  SessionJoinButton({Key key}) : super(key: key);

  @override
  _SessionJoinButtonState createState() => _SessionJoinButtonState();
}

class _SessionJoinButtonState extends State<SessionJoinButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return Consumer<BaseSessionManager>(
      builder: (context, csm, child) => Builder(builder: (context) {
        bool subscribed = csm.subscribed;
        Color background = subscribed
            ? csm.baseSession.primaryColor
            : csm.baseSession.secondaryColor;

        return JoinButton(
          joinOrLeave: csm.fromCache
              ? null
              : (bool val) => csm.leaveOrJoinSession(val, context),
          subscribed: subscribed,
          subscribedColor: csm.baseSession.primaryColor,
          notSubscribedColor: csm.baseSession.secondaryColor,
        );
      }),
    );
  }
}
