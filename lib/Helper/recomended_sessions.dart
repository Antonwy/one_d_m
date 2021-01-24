import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/CertifiedSessionsList.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:provider/provider.dart';

import 'DatabaseService.dart';
import 'News.dart';
import 'Provider/SessionManager.dart';
import 'Session.dart';
import 'keep_alive_stream.dart';

class RecomendedSessions extends StatefulWidget {
  @override
  _RecomendedSessionsState createState() => _RecomendedSessionsState();
}

class _RecomendedSessionsState extends State<RecomendedSessions> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildLatestSessionsWithPost();
  }

  Widget _buildLatestSessionsWithPost() {
    return StreamBuilder(
      stream: DatabaseService.getSessionPosts(),
      builder: (_, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        List<News> news = snapshot.data;
        news.sort((a, b) => b.createdAt?.compareTo(a.createdAt));

        List<String> sessionsWithPost = [];

        news.forEach((element) {
          sessionsWithPost.add(element.sessionId);
        });

        ///sort and add sessions with post to the begining of the list
        ///
        List<String> sessionIds = sessionsWithPost.toSet().toList();

        return StreamBuilder<List<Session>>(
            stream: DatabaseService.getCertifiedSessions(),
            builder: (context, snapshot) {
              print(snapshot);
              List<BaseSession> sessions = snapshot.data ?? [];

              if (snapshot.connectionState == ConnectionState.active &&
                  sessions.isEmpty) return SizedBox.shrink();
              List<String> allSessions = [];

              sessions.forEach((element) {
                allSessions.add(element.id);
              });

              ///add sessions that doesn't have posts

              sessionIds = [...sessionIds, ...allSessions];

              List<String> uniqueIds = sessionIds.toSet().toList();

              return Container(
                height: 160,
                child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (context, index) => SizedBox(
                          width: 8,
                        ),
                    itemBuilder: (context, index) => Padding(
                          padding: EdgeInsets.only(
                              left: index == 0 ? 12 : 0,
                              right:
                                  index == uniqueIds.length - 1 ? 12.0 : 0.0),
                          child: _buildSession(uniqueIds[index]),
                        ),
                    itemCount: uniqueIds.length),
              );
            });
      },
    );
  }

  Widget _buildSession(String sid) => KeepAliveStreamBuilder(
        stream: DatabaseService.getSession(sid),
        builder: (_, snapshot) {
          if (!snapshot.hasData) return SizedBox.shrink();
          Session s = snapshot.data;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(child: CertifiedSessionView(s)),
              _SessionJoinButton(session: s,)
            ],
          );
        },
      );
}

class _SessionJoinButton extends StatefulWidget {
  final Session session;

  _SessionJoinButton({Key key, this.session}) : super(key: key);

  @override
  __SessionJoinButtonState createState() => __SessionJoinButtonState();
}

class __SessionJoinButtonState extends State<_SessionJoinButton> {
  bool _loading = false;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    UserManager _um = Provider.of<UserManager>(context, listen: false);
    return Provider<CertifiedSessionManager>(
        create: (context) =>
            CertifiedSessionManager(session: widget.session, uid: _um.uid),
        builder: (context, child) => Consumer<CertifiedSessionManager>(
              builder: (context, csm, child) => StreamBuilder<bool>(
                  initialData: false,
                  stream: csm.isInSession,
                  builder: (context, snapshot) {
                    Color color =_theme.colors.textOnDark;
                    return MaterialButton(
                      minWidth: 133,
                      color: csm.session.secondaryColor,
                      textColor: color,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      child: _loading
                          ? Container(
                              width: 18,
                              height: 18,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 3.0,
                                  valueColor: AlwaysStoppedAnimation(color),
                                ),
                              ))
                          : AutoSizeText(
                              snapshot.data ? "Verlassen" : 'Beitreten',
                              maxLines: 1,
                            ),
                      onPressed: () async {
                        setState(() {
                          _loading = true;
                        });
                        if (snapshot.data)
                          await DatabaseService.leaveCertifiedSession(
                                  csm.baseSession.id)
                              .then((value) {
                            setState(() {
                              _loading = false;
                            });
                          });
                        else
                          await DatabaseService.joinCertifiedSession(
                                  csm.baseSession.id)
                              .then((value) {
                            setState(() {
                              _loading = false;
                            });
                          });
                      },
                    );
                  }),
            ));
  }
}
