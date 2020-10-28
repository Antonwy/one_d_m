import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Components/CustomOpenContainer.dart';
import 'package:one_d_m/Components/DonationWidget.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Donation.dart';
import 'package:one_d_m/Helper/Provider/SessionManager.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/NewCampaignPage.dart';
import 'package:one_d_m/Pages/SessionPage.dart';
import 'package:one_d_m/Pages/UserPage.dart';
import 'package:provider/provider.dart';

import 'BottomDialog.dart';
import 'DonationDialogWidget.dart';

class SessionsFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserManager>(
      builder: (context, um, child) => StreamBuilder<List<BaseSession>>(
          stream: DatabaseService.getSessionsFromUser(um.uid),
          builder: (context, snapshot) {
            List<BaseSession> sessions = snapshot.data ?? [];
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                        padding: EdgeInsets.only(
                            bottom: index == sessions.length - 1 ? 120 : 8.0),
                        child: SessionView(sessions[index]),
                      ),
                  childCount: sessions.length),
            );
          }),
    );
  }
}

class SessionView extends StatelessWidget {
  final BaseSession baseSession;
  ThemeManager _theme;

  SessionView(this.baseSession);

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return Provider<SessionManager>(
      create: (context) => SessionManager(baseSession),
      builder: (c, child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: CustomOpenContainer(
          openBuilder: (context, close, scrollController) => SessionPage(
            scrollController: scrollController,
            sessionManager: Provider.of<SessionManager>(c, listen: false),
          ),
          closedColor: Colors.white,
          closedElevation: 1,
          closedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          closedBuilder: (context, open) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Positioned.fill(
                    child: Consumer<SessionManager>(
                      builder: (context, sm, child) => StreamBuilder<Session>(
                          stream: sm.sessionStream,
                          builder: (context, snapshot) {
                            return Container(
                              decoration: snapshot.data == null
                                  ? null
                                  : BoxDecoration(
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: CachedNetworkImageProvider(
                                              snapshot.data.campaignImgUrl))),
                            );
                          }),
                    ),
                  ),
                  Positioned.fill(
                      child: Material(
                    color: _theme.colors.dark,
                  )),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Consumer<SessionManager>(
                            builder: (context, sm, child) => Text(
                              sm.baseSession.name,
                              style: _theme.textTheme.light.headline5,
                            ),
                          )),
                      _SessionDescription(),
                      _SessionMemberList(),
                      Divider(
                        height: 1,
                        color: Colors.white24,
                      ),
                      _DonateButton(),
                    ],
                  ),
                ],
              ),
              _CampaignArea(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionInfo extends StatelessWidget {
  ThemeManager _theme;

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return Row(
      children: [
        Expanded(child: _CampaignInfo()),
        Expanded(child: _TimeRemaining()),
      ],
    );
  }
}

class _SessionDescription extends StatelessWidget {
  ThemeManager _theme;

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return Consumer<SessionManager>(
      builder: (context, sm, child) => StreamBuilder<Session>(
          stream: sm.sessionStream,
          builder: (context, snapshot) {
            Session session = snapshot.data;

            if (!snapshot.hasData)
              return Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  "Laden...",
                  style: _theme.textTheme.textOnDark.bodyText1,
                ),
              );

            return Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.sessionDescription,
                    style: _theme.textTheme.light.bodyText1,
                  ),
                  SizedBox(
                    height: 12,
                  ),
                ],
              ),
            );
          }),
    );
  }
}

class _CampaignInfo extends StatelessWidget {
  ThemeManager _theme;

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return Consumer<SessionManager>(
      builder: (context, sm, child) => StreamBuilder<Session>(
          stream: sm.sessionStream,
          builder: (context, snapshot) {
            return CustomOpenContainer(
              closedColor: _theme.colors.dark,
              closedElevation: 0,
              closedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0)),
              tappable: snapshot.hasData,
              openBuilder: (context, close, scrollController) =>
                  NewCampaignPage(
                Campaign(
                    id: sm.baseSession.campaignId,
                    imgUrl: snapshot.data?.campaignImgUrl ?? "",
                    name: snapshot.data?.campaignName ?? ""),
                scrollController: scrollController,
              ),
              closedBuilder: (context, open) => Padding(
                padding: const EdgeInsets.all(12.0),
                child: Center(
                  child: Text(
                    snapshot.data?.campaignName ?? "",
                    style: _theme.textTheme.textOnDark.bodyText1
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          }),
    );
  }
}

class _TimeRemaining extends StatelessWidget {
  ThemeManager _theme;

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);

    return Material(
      color: _theme.colors.light,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: Consumer<SessionManager>(
            builder: (context, sm, child) {
              Duration diff = sm.baseSession.endDate.difference(DateTime.now());
              return RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "${diff.inHours} ",
                      style: _theme.textTheme.dark.bodyText1
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: "Stunden",
                    ),
                  ],
                  style: _theme.textTheme.dark.bodyText2,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DonateButton extends StatelessWidget {
  ThemeManager _theme;

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);

    return Consumer2<SessionManager, UserManager>(
        builder: (context, sm, um, child) => Container(
              width: double.infinity,
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: StreamBuilder<int>(
                        initialData: 0,
                        stream: DatabaseService.getDonatedAmountToSession(
                            uid: um.uid, sid: sm.baseSession.id),
                        builder: (context, snapshot) {
                          Duration diff =
                              sm.baseSession.endDate.difference(DateTime.now());
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RichText(
                                text: TextSpan(
                                    style:
                                        _theme.textTheme.textOnDark.bodyText2,
                                    children: [
                                      TextSpan(
                                          text:
                                              "${snapshot.data}/${sm.baseSession.amountPerUser} DC ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(
                                        text: "gespendet",
                                        style:
                                            _theme.textTheme.textOnDark.caption,
                                      ),
                                    ]),
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Noch ",
                                    ),
                                    TextSpan(
                                      text: "${diff.inHours} ",
                                      style: _theme
                                          .textTheme.textOnDark.bodyText1
                                          .copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: "Stunden",
                                    ),
                                  ],
                                  style: _theme.textTheme.textOnDark.caption,
                                ),
                              )
                            ],
                          );
                        }),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: OfflineBuilder(
                          child: Container(),
                          connectivityBuilder: (context, connection, child) {
                            return RaisedButton(
                              disabledTextColor: Colors.white54,
                              disabledColor: Colors.grey,
                              color: _theme.colors.contrast,
                              textColor: _theme.colors.textOnContrast,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                              onPressed: connection == ConnectivityResult.none
                                  ? null
                                  : () async {
                                      BottomDialog bd = BottomDialog(context);
                                      bd.show(DonationDialogWidget(
                                        campaign:
                                            await DatabaseService.getCampaign(
                                                sm.baseSession.campaignId),
                                        user: um.user,
                                        context: context,
                                        close: bd.close,
                                        sessionId: sm.baseSession.id,
                                      ));
                                    },
                              child: Text("UNTERSTÜTZEN"),
                            );
                          })),
                ],
              ),
            ));
  }
}

class _CampaignArea extends StatelessWidget {
  ThemeManager _theme;

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return Consumer<SessionManager>(
      builder: (context, sm, child) => StreamBuilder<Session>(
          stream: sm.sessionStream,
          builder: (context, snapshot) {
            Session session = snapshot.data;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomOpenContainer(
                    closedElevation: 0,
                    closedShape: RoundedRectangleBorder(),
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
                              style: _theme.textTheme.dark.bodyText1
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
                    child: Text(session?.campaignShortDescription ??
                        "Lade Beschreibung..."),
                  ),
                ],
              ),
            );
          }),
    );
  }
}

class _DonationArea extends StatelessWidget {
  ThemeManager _theme;

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return Consumer<SessionManager>(
      builder: (context, sm, child) => StreamBuilder<List<Donation>>(
          stream: DatabaseService.getDonationsFromSession(sm.baseSession.id),
          builder: (context, snapshot) {
            List<Donation> donations = snapshot.data ?? [];
            return Material(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        12, 12, 12, donations.isEmpty ? 12 : 6),
                    child: Text(
                      "Letzte Spenden (${donations.length})",
                      style: _theme.textTheme.dark.bodyText1,
                    ),
                  ),
                  ...donations
                      .map((don) => Material(
                            color: ThemeManager.of(context).colors.light,
                            child: DonationWidget(
                              don,
                            ),
                          ))
                      .toList()
                ],
              ),
            );
          }),
    );
  }
}

class _SessionMemberList extends StatelessWidget {
  ThemeManager _theme;

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Consumer<SessionManager>(
        builder: (context, sm, child) => Container(
            height: 150,
            child: CustomScrollView(
              scrollDirection: Axis.horizontal,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(right: 12),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                        child: RotatedBox(
                            quarterTurns: 3,
                            child: Text(
                              "Mitglieder",
                              style: _theme.textTheme.textOnDark.bodyText1,
                            ))),
                  ),
                ),
                StreamBuilder<List<SessionMember>>(
                    stream: sm.membersStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return SliverToBoxAdapter(
                          child: Center(
                              child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                      _theme.colors.contrast),
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                Text("Lade Mitglieder...",
                                    style: _theme.textTheme.contrast.bodyText1)
                              ],
                            ),
                          )),
                        );

                      List<SessionMember> members = snapshot.data ?? [];
                      return SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return Padding(
                            padding: EdgeInsets.only(
                                right: index < members.length - 1 ? 12.0 : 0.0),
                            child: _MemberView(member: members[index]),
                          );
                        }, childCount: members.length),
                      );
                    }),
                StreamBuilder<List<SessionMember>>(
                    stream: sm.invitedMembersStream,
                    builder: (context, snapshot) {
                      List<SessionMember> members = snapshot.data ?? [];
                      if (members.isEmpty) return SliverToBoxAdapter();
                      return SliverToBoxAdapter(
                          child: VerticalDivider(
                        color: Colors.white24,
                      ));
                    }),
                StreamBuilder<List<SessionMember>>(
                    stream: sm.invitedMembersStream,
                    builder: (context, snapshot) {
                      List<SessionMember> members = snapshot.data ?? [];
                      if (members.isEmpty) return SliverToBoxAdapter();
                      return SliverPadding(
                        padding: const EdgeInsets.only(right: 12),
                        sliver: SliverToBoxAdapter(
                          child: Center(
                              child: RotatedBox(
                                  quarterTurns: 3,
                                  child: Text(
                                    "Eingeladen",
                                    style:
                                        _theme.textTheme.textOnDark.bodyText1,
                                  ))),
                        ),
                      );
                    }),
                StreamBuilder<List<SessionMember>>(
                    stream: sm.invitedMembersStream,
                    builder: (context, snapshot) {
                      List<SessionMember> members = snapshot.data ?? [];
                      return SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return Padding(
                            padding: EdgeInsets.only(
                                right: index < members.length - 1 ? 12.0 : 0.0),
                            child: _MemberView(
                              member: members[index],
                              invited: true,
                            ),
                          );
                        }, childCount: members.length),
                      );
                    }),
              ],
            )),
      ),
    );
  }
}

class _MemberView extends StatelessWidget {
  final SessionMember member;
  final bool invited;
  ThemeManager _theme;

  _MemberView({Key key, this.member, this.invited = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return Consumer<SessionManager>(
      builder: (context, sm, child) => Opacity(
        opacity: invited ? .3 : 1.0,
        child: FutureBuilder<User>(
            future: DatabaseService.getUser(member.userId),
            builder: (context, snapshot) {
              User user = snapshot.data;
              return CustomOpenContainer(
                openBuilder: (context, close, scrollController) => UserPage(
                  snapshot.data,
                  scrollController: scrollController,
                ),
                closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                closedColor: _theme.colors.contrast,
                closedElevation: 1,
                closedBuilder: (context, open) => Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    user?.imgUrl == null
                        ? Container(
                            color: _theme.colors.dark,
                            height: 75,
                            width: 100,
                            child: Center(
                              child: Icon(
                                Icons.person,
                                color: _theme.colors.contrast,
                              ),
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: user.imgUrl,
                            height: 75,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                    Container(
                      height: 75,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 84,
                              child: Center(
                                child: AutoSizeText(
                                  user?.name ?? "Laden...",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: _theme
                                      .textTheme.textOnContrast.bodyText1
                                      .copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Text(
                              "${member.donationAmount}/${sm.baseSession.amountPerUser} DC",
                              style: _theme.textTheme.textOnContrast.bodyText1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }
}
