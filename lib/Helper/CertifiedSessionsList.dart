import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/CustomOpenContainer.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/keep_alive_stream.dart';
import 'package:one_d_m/Pages/CertifiedSessionPage.dart';

import 'Helper.dart';

class CertifiedSessionsList extends StatefulWidget {
  final Stream<List<Session>> stream;

  CertifiedSessionsList([this.stream]);

  @override
  _CertifiedSessionsListState createState() => _CertifiedSessionsListState();
}

class _CertifiedSessionsListState extends State<CertifiedSessionsList> {
  @override
  void initState() {
    super.initState();
    DatabaseService.getNews().listen((news) {});
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: _buildLatestSessionsWithPost(),
    );
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
                height: 120,
                child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (context, index) => SizedBox(
                          width: 8,
                        ),
                    itemBuilder: (context, index) => Padding(
                          padding: EdgeInsets.only(
                              left: index == 0 ? 12.0 : 0.0,
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
          return CertifiedSessionView(s);
        },
      );
}

class CertifiedSessionView extends StatelessWidget {
  final Session session;

  CertifiedSessionView(this.session);

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return Container(
      width: 220,
      child: CustomOpenContainer(
        closedColor: Colors.grey[200],
        closedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        closedElevation: 0,
        openBuilder: (context, close, scrollController) => CertifiedSessionPage(
          session: session,
          scrollController: scrollController,
        ),
        closedBuilder: (context, open) => Stack(
          children: [
            session?.imgUrl == null
                ? Container()
                : Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: session?.imgUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
            session?.imgUrl == null
                ? Container()
                : Positioned.fill(
                    child: Material(
                      color: Colors.black38,
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: AutoSizeText(
                        session?.name ?? '',
                        style: session?.imgUrl == null
                            ? _theme.textTheme.dark.bodyText1
                            : _theme.textTheme.light.bodyText1,
                        maxLines: 1,
                      )),
                      SizedBox(
                        width: 6,
                      ),
                      Icon(
                        Icons.verified,
                        color: Helper.hexToColor("#71e34b"),
                      )
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
