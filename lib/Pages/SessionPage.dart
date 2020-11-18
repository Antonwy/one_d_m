import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Components/BottomDialog.dart';
import 'package:one_d_m/Components/CustomOpenContainer.dart';
import 'package:one_d_m/Components/DonationDialogWidget.dart';
import 'package:one_d_m/Components/DonationWidget.dart';
import 'package:one_d_m/Components/SessionsFeed.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Donation.dart';
import 'package:one_d_m/Helper/Provider/SessionManager.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:provider/provider.dart';

import 'NewCampaignPage.dart';

class SessionPage extends StatelessWidget {
  final BaseSession baseSession;
  final ScrollController scrollController;
  ThemeManager _theme;

  SessionPage({Key key, this.baseSession, this.scrollController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);

    return Scaffold(
      backgroundColor: _theme.colors.dark,
      floatingActionButton: FloatingDonationButton(baseSession),
      body: Provider<SessionManager>(
        create: (context) => SessionManager(baseSession),
        builder: (context, child) => CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverAppBar(
              brightness: Brightness.dark,
              title: Text(baseSession.name),
              backgroundColor: _theme.colors.dark,
            ),
            SliverToBoxAdapter(
                child: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: SessionMemberList(),
            )),
            SessionInfo(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Material(
                  color: _theme.colors.contrast,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      baseSession.sessionDescription,
                      style: _theme.textTheme.textOnContrast.bodyText1,
                    ),
                  ),
                ),
              ),
            ),
            CampaignInfo<SessionManager>(),
            LastSessionDonations(),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class FloatingDonationButton extends StatelessWidget {
  BaseSession session;

  FloatingDonationButton(this.session);

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return OfflineBuilder(
        child: Container(),
        connectivityBuilder: (context, connection, child) {
          bool _connected = connection != ConnectivityResult.none;
          return Consumer<UserManager>(
            builder: (context, um, child) => FloatingActionButton.extended(
                onPressed: _connected
                    ? () async {
                        BottomDialog bd = BottomDialog(context);
                        bd.show(DonationDialogWidget(
                          campaign: await DatabaseService.getCampaign(
                              session.campaignId),
                          user: um.user,
                          context: context,
                          close: bd.close,
                          sessionId: session.id,
                        ));
                      }
                    : null,
                label: Text(
                  "Unterstützen",
                  style: TextStyle(
                      color: _connected
                          ? _theme.colors.textOnDark
                          : Colors.white60),
                ),
                backgroundColor: _connected ? _theme.colors.dark : Colors.grey),
          );
        });
  }
}

class SessionInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      sliver: SliverToBoxAdapter(
        child: Consumer<SessionManager>(
          builder: (context, sm, child) {
            Duration diff = sm.baseSession.endDate.difference(DateTime.now());
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  _SessionInfoItem(
                    head: diff.inHours.toString(),
                    sub: "Stunden",
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  StreamBuilder<Session>(
                      stream: sm.sessionStream,
                      builder: (context, snapshot) {
                        return _SessionInfoItem(
                          head: "${(snapshot.data?.currentAmount ?? 0)} DV",
                          sub: "Unterstützt",
                        );
                      }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SessionInfoItem extends StatelessWidget {
  final String head, sub;

  const _SessionInfoItem({Key key, this.head, this.sub}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return Expanded(
      child: Container(
        height: 100,
        child: Material(
          color: _theme.colors.contrast,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                head,
                style: _theme.textTheme.textOnContrast.headline5
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Text(sub, style: _theme.textTheme.textOnContrast.bodyText1),
            ],
          ),
        ),
      ),
    );
  }
}

class CampaignInfo<T extends BaseSessionManager> extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Consumer<T>(
          builder: (context, sm, child) => StreamBuilder<Session>(
              stream: sm.sessionStream,
              builder: (context, snapshot) {
                Session session = snapshot.data;
                return CustomOpenContainer(
                  closedColor: _theme.colors.contrast,
                  closedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  openBuilder: (context, close, scrollController) =>
                      NewCampaignPage(
                    Campaign(
                        id: sm.baseSession.campaignId,
                        imgUrl: snapshot.data?.campaignImgUrl ?? "",
                        name: snapshot.data?.campaignName ?? ""),
                    scrollController: scrollController,
                  ),
                  closedBuilder: (context, open) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomOpenContainer(
                          closedElevation: 0,
                          closedShape: RoundedRectangleBorder(),
                          closedColor: _theme.colors.contrast,
                          openBuilder: (context, close, scrollController) =>
                              NewCampaignPage(
                            Campaign(
                                id: sm.baseSession.campaignId,
                                imgUrl: snapshot.data?.campaignImgUrl ?? "",
                                name: snapshot.data?.campaignName ?? ""),
                            scrollController: scrollController,
                          ),
                          closedBuilder: (context, open) => InkWell(
                            onTap: session == null ? null : open,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Avatar(session?.campaignImgUrl),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Text(
                                    session?.campaignName ?? "Lade Titel...",
                                    style: _theme
                                        .textTheme.textOnContrast.bodyText1
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            session?.campaignShortDescription ??
                                "Lade Beschreibung...",
                            style: _theme.textTheme.textOnContrast.bodyText1,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }
}

class LastSessionDonations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return SliverPadding(
      padding: const EdgeInsets.all(12),
      sliver: SliverToBoxAdapter(
        child: Material(
          color: _theme.colors.contrast,
          borderRadius: BorderRadius.circular(12),
          child: Consumer<SessionManager>(
            builder: (context, sm, child) => StreamBuilder<List<Donation>>(
                stream:
                    DatabaseService.getDonationsFromSession(sm.baseSession.id),
                builder: (context, snapshot) {
                  List<Donation> donations = snapshot.data ?? [];

                  if (donations.isEmpty) return Container();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                        child: Text(
                          "Letzte Unterstützungen:",
                          style: _theme.textTheme.textOnContrast.headline6,
                        ),
                      ),
                      ...donations.map((d) => DonationWidget(
                            d,
                            backgroundLight: false,
                            textColor: _theme.colors.textOnContrast,
                          )),
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }
}
