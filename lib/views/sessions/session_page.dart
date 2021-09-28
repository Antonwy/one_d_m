import 'package:auto_size_text/auto_size_text.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/components/discovery_holder.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/components/social_share_list.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/helper/helper.dart';
import 'package:one_d_m/models/session_models/base_session.dart';
import 'package:one_d_m/models/user.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:one_d_m/utils/video/video_widget.dart';
import 'package:one_d_m/views/campaigns/create_post.dart';
import 'package:one_d_m/views/donations/donation_dialog.dart';
import 'package:one_d_m/views/home/profile_page.dart';
import 'package:one_d_m/provider/sessions_manager.dart';
import 'package:provider/provider.dart';
import 'create_session_page.dart';

class SessionPage extends StatefulWidget {
  final BaseSession session;
  final ScrollController scrollController;

  SessionPage(this.session, {this.scrollController});

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
        builder: (context, child) => Hero(
              tag: "${widget.session.id}-container",
              child: Scaffold(
                floatingActionButton: FloatingDonationButton(),
                body: CustomScrollView(
                    controller: widget?.scrollController,
                    slivers: [
                      manager.buildHeading(),
                      manager.buildTitle(),
                      manager.buildGoal(),
                      manager.buildDescription(),
                      manager.buildMembers(),
                      ...manager.buildMore(),
                      SliverToBoxAdapter(child: YMargin(100))
                    ]),
              ),
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
                    heroTag: null,
                    onPressed: _active
                        ? () async {
                            DonationDialog.show(
                              context,
                              sessionId: sm.baseSession.id,
                              donationEffects: sm.session?.donationEffects,
                            );
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
          url: "sm.session?.videoUrl",
          play: true,
          imageUrl: sm.baseSession?.imgUrl,
          muted: _muted,
          toggleMuted: _toggleMuted,
          blurHash: sm.baseSession?.blurHash,
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
                false
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
    return SliverToBoxAdapter(child: Consumer<BaseSessionManager>(
      builder: (context, sm, child) {
        return Padding(
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
                                future: Api()
                                    .users()
                                    .getOne(sm.baseSession.creatorId),
                                builder: (context, snapshot) {
                                  return RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(text: 'by '),
                                        TextSpan(
                                            text:
                                                '${snapshot.data?.name ?? 'Laden...'}',
                                            style: _theme
                                                .textTheme.dark.bodyText1
                                                .copyWith(
                                                    decoration: TextDecoration
                                                        .underline,
                                                    fontWeight:
                                                        FontWeight.w700)),
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
        );
      },
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

class SessionDescription extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Consumer<BaseSessionManager>(builder: (context, sm, child) {
        return Padding(
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
                      sm.baseSession?.description ?? "",
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
        );
      }),
    );
  }
}
