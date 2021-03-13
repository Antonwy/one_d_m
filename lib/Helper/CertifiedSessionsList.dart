import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/CustomOpenContainer.dart';
import 'package:one_d_m/Components/InfoFeed.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/keep_alive_stream.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:one_d_m/Pages/CertifiedSessionPage.dart';

import 'ColorTheme.dart';
import 'Constants.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: _buildSessions(),
    );
  }

  Widget _buildSessions() {
    return StreamBuilder<List<Session>>(
        stream: DatabaseService.getCertifiedSessions(),
        builder: (context, snapshot) {
          List<Session> sessions = snapshot.data ?? [];
          return Container(
            height: 180,
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                separatorBuilder: (context, index) => SizedBox(
                      width: 8,
                    ),
                itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.only(
                          left: index == 0 ? 12.0 : 0.0,
                          right: index == sessions.length ? 12.0 : 0.0),
                      child: sessions.length == index
                          ? _weAreWorking()
                          : CertifiedSessionView(sessions[index]),
                    ),
                itemCount: sessions.length + 1),
          );
        });
  }

  Widget _weAreWorking() {
    ThemeManager _theme = ThemeManager.of(context);
    return Container(
      width: 250,
      child: Material(
        borderRadius: BorderRadius.circular(Constants.radius),
        color: _theme.colors.contrast,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.new_releases,
                  color: _theme.colors.textOnContrast,
                ),
                YMargin(12),
                Text(
                  "Wir arbeiten hart daran, neue Sessions zu erstellen um Euch mehr Inhalt zu bieten!",
                  style: _theme.textTheme.textOnContrast.bodyText1,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CertifiedSessionView extends StatelessWidget {
  final Session session;

  CertifiedSessionView(this.session);

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Material(
        borderRadius: BorderRadius.circular(Constants.radius),
        clipBehavior: Clip.antiAlias,
        color: session.secondaryColor,
        elevation: 1,
        child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CertifiedSessionPage(
                          session: session,
                        )));
          },
          child: SizedBox(
            width: 230,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CachedNetworkImage(
                  imageUrl: session.imgUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                  child: Text(
                    session.name,
                    style: _theme.textTheme.light.bodyText1,
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(8, 0, 14, 0),
                  child: Row(
                    children: [
                      Text(
                        "${((session.donationGoalCurrent / session.donationGoal) * 100).round()}%",
                        style: _theme.textTheme.light.bodyText2,
                      ),
                      XMargin(12),
                      Expanded(
                        child: PercentLine(
                          percent: session.donationGoalCurrent /
                              session.donationGoal,
                          height: 8.0,
                          color: _theme.colors.light,
                        ),
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

    return Material(
      borderRadius: BorderRadius.circular(Constants.radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CertifiedSessionPage(
                        session: session,
                      )));
        },
        child: Column(
          children: [
            CachedNetworkImage(
              imageUrl: session?.imgUrl,
              fit: BoxFit.cover,
              height: 50,
              width: 50,
            ),
            Row(
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
            ),
          ],
        ),
      ),
    );
  }
}
