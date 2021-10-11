import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/components/avatar.dart';
import 'package:one_d_m/helper/database_service.dart';
import 'package:one_d_m/models/session_models/session.dart';
import 'package:one_d_m/models/session_models/session_invite.dart';
import 'package:one_d_m/models/user.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:provider/provider.dart';

class SessionInvitesFeed extends StatelessWidget {
  final List<SessionInvite>? invites;

  SessionInvitesFeed(this.invites);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManager>(
      builder: (context, um, child) => StreamBuilder<List<SessionInvite>>(
          stream: DatabaseService.getSessionInvites(um.uid),
          initialData: invites,
          builder: (context, snapshot) {
            List<SessionInvite> invites = snapshot.data!;
            return SliverToBoxAdapter(
                child: invites.isEmpty
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              "assets/images/invites.svg",
                              height: 120,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Column(
                              children: invites
                                  .map((inv) => _InviteMessage(
                                        inv,
                                        returnAfter: invites.length == 1,
                                      ))
                                  .toList(),
                            )
                          ],
                        ),
                      ));
          }),
    );
  }
}

class _InviteMessage extends StatefulWidget {
  final SessionInvite invite;
  final bool? returnAfter;

  _InviteMessage(this.invite, {this.returnAfter});

  @override
  __InviteMessageState createState() => __InviteMessageState();
}

class __InviteMessageState extends State<_InviteMessage> {
  late ThemeManager _theme;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);

    return FutureBuilder<User>(
        future: DatabaseService.getUser(widget.invite.sessionCreatorId),
        builder: (context, snapshot) {
          User? user = snapshot.data;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Material(
              color: Colors.white,
              elevation: 1,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Avatar(user?.imgUrl),
                            _loading
                                ? CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(
                                        _theme.colors!.contrast),
                                  )
                                : Container(),
                          ],
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.invite.sessionName!,
                              style: _theme.textTheme.dark!.bodyText1,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              user == null
                                  ? "Laden..."
                                  : "${user.name} hat sie zu einer CertifiedSession eingeladen.",
                              style: _theme.textTheme.dark!.caption,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: OutlineButton.icon(
                            icon: Icon(Icons.done),
                            label: Text("Annehmen"),
                            onPressed: _loading
                                ? null
                                : () async {
                                    if (widget.returnAfter!)
                                      Navigator.pop(context);
                                    else
                                      setState(() {
                                        _loading = true;
                                      });
                                    await DatabaseService.acceptSessionInvite(
                                        widget.invite);
                                  },
                            textColor: Colors.green,
                            highlightedBorderColor: Colors.green,
                          ),
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: OutlineButton.icon(
                            icon: Icon(Icons.close),
                            label: Text("Ablehnen"),
                            onPressed: _loading
                                ? null
                                : () async {
                                    if (widget.returnAfter!)
                                      Navigator.pop(context);
                                    else
                                      setState(() {
                                        _loading = true;
                                      });
                                    await DatabaseService.declineSessionInvite(
                                        widget.invite);
                                    if (widget.returnAfter!)
                                      Navigator.pop(context);
                                  },
                            textColor: Colors.red,
                            highlightedBorderColor: Colors.red,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
