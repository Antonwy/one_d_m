import 'package:flutter/material.dart';
import 'package:one_d_m/components/join_button.dart';
import 'package:one_d_m/provider/sessions_manager.dart';
import 'package:provider/provider.dart';

class SessionJoinButton extends StatefulWidget {
  SessionJoinButton({Key? key}) : super(key: key);

  @override
  _SessionJoinButtonState createState() => _SessionJoinButtonState();
}

class _SessionJoinButtonState extends State<SessionJoinButton> {
  @override
  Widget build(BuildContext context) {
    return Consumer<BaseSessionManager>(builder: (context, csm, child) {
      bool subscribed = csm.subscribed;

      return JoinButton(
        joinOrLeave: (bool val) => csm.leaveOrJoinSession(val, context),
        subscribed: subscribed,
        subscribedColor: csm.baseSession!.primaryColor,
        notSubscribedColor: csm.baseSession!.secondaryColor,
      );
    });
  }
}
