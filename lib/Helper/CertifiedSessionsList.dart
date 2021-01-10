import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/CustomOpenContainer.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Pages/CertifiedSessionPage.dart';

import 'Helper.dart';

class CertifiedSessionsList extends StatelessWidget {
  final Stream<List<Session>> stream;

  CertifiedSessionsList([this.stream]);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: StreamBuilder<List<Session>>(
          stream: stream ?? DatabaseService.getCertifiedSessions(),
          builder: (context, snapshot) {
            print(snapshot);
            List<BaseSession> sessions = snapshot.data ?? [];

            if (snapshot.connectionState == ConnectionState.active &&
                sessions.isEmpty) return Container();

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
                            right: index == sessions.length - 1 ? 12.0 : 0.0),
                        child: CertifiedSessionView(sessions[index]),
                      ),
                  itemCount: sessions.length),
            );
          }),
    );
  }
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
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        closedElevation: 0,
        openBuilder: (context, close,scrollController) => CertifiedSessionPage(
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
                        session.name??'',
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
