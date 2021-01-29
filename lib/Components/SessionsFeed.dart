import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Components/CustomOpenContainer.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Provider/SessionManager.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:one_d_m/Pages/NewCampaignPage.dart';
import 'package:one_d_m/Pages/SessionPage.dart';
import 'package:one_d_m/Pages/UserPage.dart';
import 'package:provider/provider.dart';

import 'BottomDialog.dart';
import 'DonationDialogWidget.dart';
import 'DonationWidget.dart';
import 'UserFollowButton.dart';

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

  SessionView(this.baseSession);

  @override
  Widget build(BuildContext context) {
    return Provider<SessionManager>(
        create: (context) => SessionManager(baseSession),
        builder: (c, child) => _ProvidedSessionView());
  }
}

class _ProvidedSessionView extends StatelessWidget {
  ThemeManager _theme;

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Builder(builder: (context) {
        return Consumer<SessionManager>(
          builder: (context, sm, child) => CustomOpenContainer(
            openBuilder: (c, close, scrollController) => SessionPage(
              scrollController: scrollController,
              baseSession: sm.baseSession,
            ),
            closedColor: Colors.white,
            closedElevation: 1,
            closedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            closedBuilder: (context, open) => Provider<SessionManager>(
              create: (context) => sm,
              builder: (context, child) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Positioned.fill(
                        child: StreamBuilder<Session>(
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
                      Positioned.fill(
                          child: Material(
                        color: _theme.colors.dark,
                      )),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                sm.baseSession.name,
                                style: _theme.textTheme.light.headline5,
                              )),
                          _SessionDescription(),
                          SessionMemberList(),
                          SizedBox(
                            height: 12,
                          ),
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
      }),
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
                                              "${snapshot.data}/${sm.baseSession.amountPerUser} DV ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(
                                        text: "unterstützt",
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

class SessionMemberList extends StatelessWidget {
  ThemeManager _theme;

  SessionMemberList({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Consumer<SessionManager>(
        builder: (context, sm, child) => SizedBox(
            height: 150,
            child: CustomScrollView(
              scrollDirection: Axis.horizontal,
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 150,
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
                                left: index <= members.length - 1 ? 12.0 : 0.0),
                            child: SessionMemberView<SessionManager>(
                                member: members[index]),
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
                      if (members.isEmpty)
                        return SliverToBoxAdapter(
                          child: SizedBox(
                            width: 12,
                          ),
                        );
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
                                right:
                                    index <= members.length - 1 ? 12.0 : 0.0),
                            child: SessionMemberView<SessionManager>(
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

class SessionMemberView<T extends BaseSessionManager> extends StatelessWidget {
  final SessionMember member;
  final bool invited, showTargetAmount;
  final Color color, avatarColor, avatarBackColor;
  ThemeManager _theme;

  SessionMemberView(
      {Key key,
      this.member,
      this.color = ColorTheme.wildGreen,
      this.avatarColor,
      this.avatarBackColor,
      this.invited = false,
      this.showTargetAmount = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return Consumer<T>(
      builder: (context, sm, child) => Opacity(
        opacity: invited ? .3 : 1.0,
        child: FutureBuilder<User>(
            future: DatabaseService.getUser(member.userId),
            builder: (context, snapshot) {
              User user = snapshot.data;

              return Container(
                width: 108,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: CustomOpenContainer(
                    openBuilder: (context, close, scrollController) => UserPage(
                      user,
                      scrollController: scrollController,
                    ),
                    tappable: user != null,
                    closedElevation: 0,
                    closedColor: color.withOpacity(.45),
                    closedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Constants.radius)),
                    closedBuilder: (context, open) => Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          RoundedAvatar(
                            user?.imgUrl,
                            loading: !snapshot.hasData,
                            color: _theme.colors.dark,
                            iconColor: _theme.colors.contrast,
                            height: 30,
                          ),
                          YMargin(6),
                          Container(
                            width: 76,
                            height: 20,
                            child: Center(
                              child: AutoSizeText(
                                  "${member?.donationAmount ?? 0} DV",
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          YMargin(6),
                          UserFollowButton(
                              followerId: user?.id,
                              color: color,
                              textColor: Colors.white,
                              backOpacity: .5),
                        ],
                      ),
                    ),
                  ),
                ),
              );

              return CustomOpenContainer(
                openBuilder: (context, close, scrollController) => UserPage(
                  snapshot.data,
                  scrollController: scrollController,
                ),
                tappable: user != null,
                closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                closedColor: color,
                closedElevation: 1,
                closedBuilder: (context, open) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    user?.imgUrl == null
                        ? Container(
                            color: avatarBackColor ?? _theme.colors.dark,
                            height: 75,
                            width: 100,
                            child: Center(
                              child: Icon(
                                Icons.person,
                                color: avatarColor ?? _theme.colors.contrast,
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
                      height: showTargetAmount ? 75 : 50,
                      width: 84,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: AutoSizeText(
                                user?.name ?? "Laden...",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _theme.textTheme.textOnContrast.bodyText1
                                    .copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: _theme.colors.textOnDark),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            showTargetAmount
                                ? Text(
                                    "${member.donationAmount} DV",
                                    style: _theme
                                        .textTheme.textOnContrast.bodyText1
                                        .copyWith(
                                            color: _theme.colors.textOnDark),
                                  )
                                : Container(),
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
