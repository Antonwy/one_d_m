import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/models/session_models/base_session.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/views/sessions/session_page.dart';

import 'long_session_list.dart';

class SessionHolder extends StatelessWidget {
  final List<BaseSession> sessions;
  final int minSessionsToShow;

  const SessionHolder(this.sessions, {this.minSessionsToShow = 3});

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: OpenContainer(
            closedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Constants.radius)),
            closedColor: _theme.colors.contrast,
            openBuilder: (context, close) => LongSessionList(sessions),
            closedBuilder: (context, open) =>
                LayoutBuilder(builder: (context, contraints) {
                  return Wrap(
                    children: _buildGrid(
                        itemSize: contraints.maxWidth / 2,
                        context: context,
                        theme: _theme,
                        open: open),
                  );
                })),
      ),
    );
  }

  List<Widget> _buildGrid(
      {double itemSize,
      BuildContext context,
      ThemeManager theme,
      Function open}) {
    List<Widget> widgets = [];
    double padding = 10, halfPadding = padding / 2;

    List<BaseSession> shortedSessions =
        sessions.sublist(minSessionsToShow, minSessionsToShow + 3);

    int i;

    EdgeInsets paddingFromI(int i) => EdgeInsets.fromLTRB(
        i % 2 == 0 ? padding : halfPadding,
        i < 2 ? padding : halfPadding,
        (i + 1) % 2 == 0 ? padding : halfPadding,
        i > 1 ? padding : halfPadding);

    for (i = 0; i < shortedSessions.length; i++) {
      BaseSession session = shortedSessions[i];
      widgets.add(Container(
          width: itemSize,
          height: itemSize,
          child: Padding(
            padding: paddingFromI(i),
            child: Material(
              borderRadius: BorderRadius.circular(Constants.radius - 4),
              clipBehavior: Clip.antiAlias,
              color: session.primaryColor,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SessionPage(session)));
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: session.imgUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => session?.blurHash != null
                          ? BlurHash(hash: session.blurHash)
                          : Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(theme
                                    .correctColorFor(session.primaryColor)),
                              ),
                            ),
                    ),
                    if (session.isCertified)
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Icon(
                          Icons.verified,
                          color: Colors.greenAccent[400],
                          size: 16,
                        ),
                      )
                  ],
                ),
              ),
            ),
          )));
    }

    widgets.add(Container(
      width: itemSize,
      height: itemSize,
      child: Padding(
        padding: paddingFromI(i),
        child: Material(
          borderRadius: BorderRadius.circular(Constants.radius - 4),
          color: theme.colors.dark.withOpacity(.15),
          child: Icon(
            Icons.more_horiz,
            color: theme.colors.dark,
          ),
        ),
      ),
    ));

    return widgets;
  }
}
