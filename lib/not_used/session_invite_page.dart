import 'package:flutter/material.dart';
import 'package:one_d_m/models/session_models/session_invite.dart';
import 'package:one_d_m/not_used/session_invites_feed.dart';
import 'package:one_d_m/provider/theme_manager.dart';

class SessionInvitesPage extends StatelessWidget {
  final List<SessionInvite> invites;
  final ScrollController scrollController;

  SessionInvitesPage({Key key, this.invites, this.scrollController})
      : super(key: key);

  ThemeManager _theme;

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: _theme.colors.dark),
            title: Text(
              "Session Einladungen (${invites.length})",
              style: TextStyle(color: _theme.colors.dark),
            ),
          ),
          SessionInvitesFeed(invites),
        ],
      ),
    );
  }
}
