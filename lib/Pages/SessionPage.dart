import 'package:auto_size_text/auto_size_text.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:one_d_m/Components/BottomDialog.dart';
import 'package:one_d_m/Components/CustomOpenContainer.dart';
import 'package:one_d_m/Components/DiscoveryHolder.dart';
import 'package:one_d_m/Components/DonationDialogWidget.dart';
import 'package:one_d_m/Components/DonationWidget.dart';
import 'package:one_d_m/Components/InfoFeed.dart';
import 'package:one_d_m/Components/SocialShareList.dart';
import 'package:one_d_m/Components/UserFollowButton.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Donation.dart';
import 'package:one_d_m/Helper/DynamicLinkManager.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/Numeral.dart';
import 'package:one_d_m/Helper/Provider/SessionManager.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/ShareImage.dart';
import 'package:one_d_m/Helper/ShareManager.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:one_d_m/utils/video/video_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:social_share/social_share.dart';

import 'CertifiedSessionPage.dart';
import 'CreateSessionPage.dart';
import 'HomePage/ProfilePage.dart';
import 'NewCampaignPage.dart';
import 'UserPage.dart';
import 'create_post.dart';

class SessionPage extends StatefulWidget {
  final BaseSession session;

  SessionPage(this.session);

  @override
  _SessionPageState createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  BaseSessionManager manager;

  @override
  void initState() {
    super.initState();
    manager = widget.session.manager(context.read<UserManager>().uid);
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      FeatureDiscovery.discoverFeatures(
          context, DiscoveryHolder.sessionCampaignFeatures);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BaseSessionManager>(
        create: (context) => manager,
        builder: (context, child) => Scaffold(
              floatingActionButton: FloatingDonationButton(),
              body: CustomScrollView(slivers: [
                manager.buildHeading(),
                manager.buildTitle(),
                manager.buildGoal(),
                manager.buildDescription(),
                manager.buildMembers(),
                ...manager.buildMore(),
                SliverToBoxAdapter(child: YMargin(100))
              ]),
            ));
  }
}

class FloatingDonationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return DiscoveryHolder.donateButton(
      tapTarget: Icon(
        Icons.arrow_forward,
        color: _theme.colors.contrast,
      ),
      child: OfflineBuilder(
          child: Container(),
          connectivityBuilder: (context, connection, child) {
            bool _connected = connection != ConnectivityResult.none;
            return Consumer2<UserManager, BaseSessionManager>(
              builder: (context, um, sm, child) {
                if (sm.isPreview) return SizedBox.shrink();

                bool _active = _connected && sm.baseSession?.campaignId != null;
                Color textColor = _theme.correctColorFor(
                    sm.baseSession.secondaryColor ?? _theme.colors.dark);
                return FloatingActionButton.extended(
                    onPressed: _active
                        ? () async {
                            BottomDialog bd = BottomDialog(context);
                            bd.show(DonationDialogWidget(
                              campaign: await sm.campaign,
                              user: um.user,
                              context: context,
                              close: bd.close,
                              sessionId: sm.baseSession.id,
                              uid: um.uid,
                            ));
                          }
                        : null,
                    label: Text(
                      "Unterstützen",
                      style: TextStyle(
                          color: _active ? textColor : Colors.white60),
                    ),
                    backgroundColor: _active
                        ? sm.baseSession.secondaryColor ?? _theme.colors.dark
                        : Colors.grey);
              },
            );
          }),
    );
  }
}

class SessionTitleImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Stack(
        children: [
          Consumer<BaseSessionManager>(
              builder: (context, bsm, child) => _buildImage(context, bsm)),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            right: 12,
            left: 12,
            child: Consumer<BaseSessionManager>(
              builder: (context, sm, child) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppBarButton(
                      elevation: 10,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icons.arrow_back),
                  if (!sm.isPreview)
                    Consumer<UserManager>(
                      builder: (context, um, child) {
                        bool isCreator = um.uid == sm?.baseSession?.creatorId;
                        return Row(
                          children: [
                            DiscoveryHolder.shareButton(
                              tapTarget: Icon(
                                CupertinoIcons.share,
                                color: ThemeManager.of(context).colors.contrast,
                              ),
                              child: AppBarButton(
                                elevation: 10,
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            title: Text(
                                                "${sm.baseSession.name} teilen"),
                                            content: SocialShareList(
                                              sm,
                                              onClicked: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Constants.radius)),
                                          ));
                                },
                                icon: CupertinoIcons.share,
                              ),
                            ),
                            if (isCreator) XMargin(8),
                            if (isCreator)
                              AppBarButton(
                                elevation: 10,
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            CreateSessionPage(sm))),
                                icon: Icons.edit,
                              ),
                            if (isCreator) XMargin(8),
                            if (isCreator)
                              AppBarButton(
                                elevation: 10,
                                onPressed: () async {
                                  bool res = (await Helper.showWarningAlert(
                                          context,
                                          "Bist du dir sicher, dass du ${sm.baseSession.name} löschen willst?",
                                          title: "Sicher?",
                                          acceptButton: "LÖSCHEN")) ??
                                      false;
                                  if (res) {
                                    sm.delete();
                                    Navigator.pop(context);
                                  }
                                },
                                icon: Icons.delete,
                                iconColor: Colors.red,
                              ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context, BaseSessionManager bsm) {
    return Container(
      height: MediaQuery.of(context).size.width,
      width: double.infinity,
      child: Builder(
        builder: (context) {
          Color secondaryColor = bsm.baseSession.secondaryColor;
          return Material(
              color: secondaryColor, child: bsm.buildHeadingImage());
        },
      ),
    );
  }
}

class SessionVideoHeading extends StatefulWidget {
  @override
  _SessionVideoHeadingState createState() => _SessionVideoHeadingState();
}

class _SessionVideoHeadingState extends State<SessionVideoHeading> {
  bool _muted = true;

  void _toggleMuted() {
    setState(() {
      _muted = !_muted;
    });
  }

  @override
  Widget build(BuildContext context) {
    CertifiedSessionManager sm = context.read<BaseSessionManager>();
    return Stack(
      children: [
        VideoWidget(
          height: MediaQuery.of(context).size.width,
          url: sm.session?.videoUrl,
          play: true,
          imageUrl: sm.session?.imgUrl,
          muted: _muted,
          toggleMuted: _toggleMuted,
          blurHash: sm.session?.blurHash,
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                sm.session?.videoUrl != null && sm.session.videoUrl.isNotEmpty
                    ? MuteButton(
                        muted: _muted,
                        toggle: _toggleMuted,
                      )
                    : SizedBox.shrink(),
                SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SessionTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return SliverToBoxAdapter(
        child: Consumer<BaseSessionManager>(
      builder: (context, sm, child) => Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            flex: 6,
                            child: AutoSizeText(
                              sm.baseSession?.name ?? "Laden...",
                              maxLines: 1,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: _theme.colors.dark),
                            ),
                          ),
                          if (sm.baseSession.isCertified) XMargin(6),
                          if (sm.baseSession.isCertified)
                            Icon(Icons.verified,
                                color: Colors.greenAccent[400], size: 18),
                        ],
                      ),
                      sm.baseSession?.creatorId?.isNotEmpty ?? false
                          ? FutureBuilder<User>(
                              future: DatabaseService.getUser(
                                  sm.baseSession.creatorId),
                              builder: (context, snapshot) {
                                return RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(text: 'by '),
                                      TextSpan(
                                          text:
                                              '${snapshot.data?.name ?? 'Laden...'}',
                                          style: _theme.textTheme.dark.bodyText1
                                              .copyWith(
                                                  decoration:
                                                      TextDecoration.underline,
                                                  fontWeight: FontWeight.w700)),
                                    ],
                                    style: _theme.textTheme.dark.bodyText1
                                        .copyWith(
                                            color: _theme.colors.dark
                                                .withOpacity(.54)),
                                  ),
                                );
                              },
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
                XMargin(12),
                if (!sm.isPreview)
                  Expanded(
                    flex: 3,
                    child: sm.buildJoinButton(),
                  )
              ],
            ),
          ],
        ),
      ),
    ));
  }
}

class CreatePostButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return Consumer<BaseSessionManager>(
      builder: (context, sm, child) => ElevatedButton(
          style: ElevatedButton.styleFrom(primary: sm.baseSession.primaryColor),
          child: AutoSizeText("Post erstellen",
              maxLines: 1,
              style: _theme.textTheme
                  .correctColorFor(sm.baseSession.primaryColor)
                  .bodyText1),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreatePostScreen(
                          isSession: true,
                          session: sm.baseSession,
                        )));
          }),
    );
  }
}

class SessionJoinButton extends StatefulWidget {
  SessionJoinButton({Key key}) : super(key: key);

  @override
  _SessionJoinButtonState createState() => _SessionJoinButtonState();
}

class _SessionJoinButtonState extends State<SessionJoinButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return Consumer<BaseSessionManager>(
      builder: (context, csm, child) => StreamBuilder<bool>(
          initialData: false,
          stream: csm.isInSession,
          builder: (context, snapshot) {
            Color background = snapshot.data
                ? csm.baseSession.primaryColor
                : csm.baseSession.secondaryColor;
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: background,
              ),
              child: _loading
                  ? Container(
                      width: 18,
                      height: 18,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 3.0,
                          valueColor: AlwaysStoppedAnimation(
                              _theme.correctColorFor(background)),
                        ),
                      ))
                  : AutoSizeText(
                      snapshot.data ? "VERLASSEN" : 'BEITRETEN',
                      maxLines: 1,
                      style: _theme.textTheme
                          .correctColorFor(background)
                          .bodyText1,
                    ),
              onPressed: () async {
                setState(() {
                  _loading = true;
                });
                if (snapshot.data) {
                  await DatabaseService.leaveCertifiedSession(
                          csm.baseSession.id)
                      .then((value) {
                    setState(() {
                      _loading = false;
                    });
                  });
                  await context.read<FirebaseAnalytics>().logEvent(
                      name: "Left CertifiedSession",
                      parameters: {"session": csm.baseSession.id});
                } else {
                  await DatabaseService.joinCertifiedSession(csm.baseSession.id)
                      .then((value) {
                    setState(() {
                      _loading = false;
                    });
                  });
                  await context.read<FirebaseAnalytics>().logEvent(
                      name: "Joined CertifiedSession",
                      parameters: {"session": csm.baseSession.id});
                }
              },
            );
          }),
    );
  }
}

class SessionGoal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BaseSessionManager sm = context.watch<BaseSessionManager>();
    ThemeManager _theme = ThemeManager.of(context);
    BaseSession session = sm?.baseSession;
    return SliverToBoxAdapter(
      child: (session?.donationGoal ?? 0) > 0 &&
              session?.donationUnit != null &&
              session?.donationUnitEffect != null
          ? FutureBuilder<Campaign>(
              future: sm.campaign,
              builder: (context, snapshot) {
                Color textColor =
                    _theme.correctColorFor(sm.baseSession.secondaryColor);
                BaseTextTheme textTheme = _theme.textTheme
                    .correctColorFor(sm.baseSession.secondaryColor);
                Campaign campaign = snapshot.data;
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Material(
                        color: session.secondaryColor,
                        borderRadius: BorderRadius.circular(Constants.radius),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                  child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                              text:
                                                  "${Numeral(session.donationGoalCurrent).value()} "),
                                          if (campaign?.unitSmiley != null &&
                                              (campaign
                                                      ?.unitSmiley?.isNotEmpty ??
                                                  false))
                                            TextSpan(
                                                text: "${campaign?.unitSmiley}",
                                                style: TextStyle(
                                                    fontSize: 38,
                                                    fontWeight:
                                                        FontWeight.w300))
                                          else
                                            TextSpan(
                                                text:
                                                    "${campaign?.unit ?? "DV"}",
                                                style: TextStyle(
                                                    fontSize: 22,
                                                    fontWeight:
                                                        FontWeight.w300))
                                        ],
                                        style: textTheme.headline5.copyWith(
                                            fontSize: 38,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    YMargin(8),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          border: Border.all(color: textColor)),
                                      child: Material(
                                        color: Colors.transparent,
                                        clipBehavior: Clip.antiAlias,
                                        borderRadius: BorderRadius.circular(24),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        NewCampaignPage(
                                                            campaign)));
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4.0, horizontal: 12),
                                            child: Text(
                                                "${campaign?.name ?? "Laden..."}",
                                                style: textTheme.bodyText1),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )),
                              YMargin(6),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6.0),
                                child: LayoutBuilder(
                                    builder: (context, constraints) {
                                  return Container(
                                    width: constraints.maxWidth,
                                    child: PercentLine(
                                      percent: (session.donationGoalCurrent /
                                              session.donationGoal)
                                          .clamp(0.0, 1.0),
                                      height: 10.0,
                                      color: textColor,
                                    ),
                                  );
                                }),
                              ),
                              YMargin(6.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${_formatPercent(session)}% erreicht",
                                    style: textTheme.bodyText1,
                                  ),
                                  RichText(
                                      text: TextSpan(
                                          style: textTheme.bodyText1.copyWith(
                                              fontWeight: FontWeight.w400),
                                          children: [
                                        TextSpan(
                                          text: "Ziel: ",
                                        ),
                                        TextSpan(
                                            text: "${session.donationGoal} ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        TextSpan(
                                            text:
                                                "${campaign?.unitSmiley ?? campaign?.unit ?? "DV"}"),
                                      ])),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              })
          : SizedBox.shrink(),
    );
  }

  String _formatPercent(BaseSession session) {
    double percentValue =
        (session.donationGoalCurrent / session.donationGoal) * 100;

    if (percentValue < 1) return percentValue.toStringAsFixed(2);
    if ((percentValue % 1) == 0) return percentValue.toInt().toString();

    return percentValue.toStringAsFixed(1);
  }
}

class SessionDescription extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Consumer<BaseSessionManager>(
          builder: (context, sm, child) => Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                child: Material(
                    borderRadius: BorderRadius.circular(Constants.radius),
                    color: sm.baseSession.primaryColor,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sm.baseSession.sessionDescription,
                            style: ThemeManager.of(context)
                                .textTheme
                                .correctColorFor(sm.baseSession.primaryColor)
                                .bodyText2,
                          ),
                          if (!sm.isPreview) YMargin(12),
                          if (!sm.isPreview)
                            Text(
                              "Teile diese Session mit deinen Freunden:",
                              style: ThemeManager.of(context)
                                  .textTheme
                                  .correctColorFor(sm.baseSession.primaryColor)
                                  .bodyText1,
                            ),
                          if (!sm.isPreview) YMargin(6),
                          if (!sm.isPreview) SocialShareList(sm)
                        ],
                      ),
                    )),
              )),
    );
  }
}

class SessionMembers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return SliverToBoxAdapter(
      child: Consumer<BaseSessionManager>(
        builder: (context, sm, child) => StreamBuilder<List<SessionMember>>(
            initialData: [],
            stream: sm.membersStream,
            builder: (context, memberSnapshot) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  memberSnapshot.data.isEmpty
                      ? SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 6),
                          child: Text(
                            "Mitglieder",
                            style: _theme.textTheme.dark.bodyText1,
                          ),
                        ),
                  SizedBox(
                      height: 155,
                      child: Builder(builder: (context) {
                        List<SessionMember> members = memberSnapshot.data;
                        if (members.isNotEmpty) {
                          return FutureBuilder<Campaign>(
                              future: sm.campaign,
                              builder: (context, campaignSnapshot) {
                                return ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: members.length,
                                    itemBuilder: (context, index) => Padding(
                                          padding: EdgeInsets.only(
                                              left: index == 0 ? 6.0 : 0.0,
                                              right: index == members.length - 1
                                                  ? 6.0
                                                  : 0.0),
                                          child: SessionMemberView(
                                              member: members[index],
                                              showTargetAmount: true,
                                              color: sm.baseSession
                                                      ?.primaryColor ??
                                                  _theme.colors.dark,
                                              avatarColor: Colors.white,
                                              avatarBackColor:
                                                  sm.baseSession.secondaryColor,
                                              donationUnit:
                                                  campaignSnapshot.data?.unit ??
                                                      "DV",
                                              dvController: campaignSnapshot
                                                      .data?.dvController ??
                                                  1),
                                        ));
                              });
                        } else {
                          return SizedBox.shrink();
                        }
                      })),
                ],
              );
            }),
      ),
    );
  }
}

class SessionMemberView extends StatelessWidget {
  final SessionMember member;
  final bool invited, showTargetAmount, showFollowButton, clickable;
  final Color color, avatarColor, avatarBackColor;
  final String donationUnit;
  final int dvController;
  ThemeManager _theme;

  SessionMemberView(
      {Key key,
      this.member,
      this.color = ColorTheme.wildGreen,
      this.avatarColor,
      this.avatarBackColor,
      this.invited = false,
      this.showTargetAmount = true,
      this.showFollowButton = true,
      this.donationUnit = "DV",
      this.dvController = 1,
      this.clickable = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return Consumer<BaseSessionManager>(
      builder: (context, sm, child) => Opacity(
        opacity: invited ? .3 : 1.0,
        child: FutureBuilder<User>(
            future: DatabaseService.getUser(member.userId),
            builder: (context, snapshot) {
              User user = snapshot.data;

              return Container(
                width: showFollowButton ? 108 : 90,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: CustomOpenContainer(
                    openBuilder: (context, close, scrollController) => UserPage(
                      user,
                      scrollController: scrollController,
                    ),
                    tappable: user != null && clickable,
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
                            name: user?.name,
                          ),
                          YMargin(6),
                          Container(
                            width: 76,
                            height: 25,
                            child: Center(
                              child: AutoSizeText(
                                  "${user?.name ?? 'Laden...'}\n${Numeral(((member?.donationAmount ?? 0) / dvController).round()).value()} $donationUnit",
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  style: TextStyle(
                                      color: _theme.correctColorFor(color),
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          if (showFollowButton) YMargin(6),
                          if (showFollowButton)
                            UserFollowButton(
                                followerId: user?.id,
                                color: color,
                                textColor: _theme.correctColorFor(color),
                                backOpacity: .5),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}

class SessionLastDonationsTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SessionManager sm = context.read<BaseSessionManager>();
    return SliverToBoxAdapter(
      child: StreamBuilder<List<Donation>>(
          initialData: [],
          stream: sm.lastDonationsStream,
          builder: (context, snapshot) {
            if (snapshot.data.isEmpty) return SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Text(
                "Letzte Unterstützungen",
                style: ThemeManager.of(context).textTheme.dark.bodyText1,
              ),
            );
          }),
    );
  }
}

class SessionLastDonations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SessionManager sm = context.read<BaseSessionManager>();
    return StreamBuilder<List<Donation>>(
        initialData: [],
        stream: sm.lastDonationsStream,
        builder: (context, snapshot) {
          return SliverList(
              delegate: SliverChildBuilderDelegate(
                  (context, index) => DonationWidget(snapshot.data[index]),
                  childCount: snapshot.data.length));
        });
  }
}
