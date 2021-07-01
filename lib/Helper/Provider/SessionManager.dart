import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Donation.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Pages/SessionPage.dart';
import 'package:one_d_m/utils/video/video_widget.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import '../DynamicLinkManager.dart';
import '../ThemeManager.dart';
import '../UserManager.dart';
import '../margin.dart';

abstract class BaseSessionManager extends ChangeNotifier {
  BaseSession baseSession;
  final bool isPreview;
  final String uid;
  Stream<List<SessionMember>> membersStream;
  Stream<List<Donation>> donationStream;
  Stream<BaseSession> sessionStream;
  StreamSubscription sessionStreamSubscription;
  Future<Campaign> campaign;
  Stream<bool> isInSession;

  bool _mounted = true;
  void initStreams();

  BaseSessionManager(this.baseSession, {this.isPreview = false, this.uid}) {
    isInSession = DatabaseService.userIsInSession(uid, baseSession.id);
    sessionStream = DatabaseService.getSession(baseSession.id);
    sessionStreamSubscription = sessionStream.listen((s) {
      baseSession = s;
      if (_mounted) notifyListeners();
    });
    campaign = DatabaseService.getCampaign(baseSession.campaignId);
    initStreams();
  }

  @override
  void dispose() {
    _mounted = false;
    sessionStreamSubscription.cancel();
    super.dispose();
  }

  Future<void> share(BuildContext context) async {
    if ((baseSession?.name?.isEmpty ?? true) ||
        (baseSession.imgUrl?.isEmpty ?? true)) return;
    Share.share(
        (await DynamicLinkManager.of(context).createSessionLink(baseSession))
            .toString());
  }

  Widget buildHeading() {
    return SessionTitleImage();
  }

  Widget buildHeadingImage() {
    return Builder(
        builder: (context) => CachedNetworkImage(
              height: MediaQuery.of(context).size.width,
              width: double.infinity,
              imageUrl: baseSession?.imgUrl ?? "",
              fit: BoxFit.cover,
              placeholder: (context, _) => baseSession.blurHash != null
                  ? BlurHash(hash: baseSession.blurHash)
                  : Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(
                            ThemeManager.of(context).colors.dark),
                      ),
                    ),
            ));
  }

  Widget buildTitle() {
    return SessionTitle();
  }

  Widget buildJoinButton() {
    return baseSession?.creatorId?.isNotEmpty ?? true
        ? Consumer<UserManager>(
            builder: (context, um, child) => um.uid == baseSession.creatorId
                ? CreatePostButton()
                : SessionJoinButton())
        : SessionJoinButton();
  }

  Widget buildGoal() {
    return SessionGoal();
  }

  Widget buildDescription() {
    return SessionDescription();
  }

  Widget buildMembers() {
    return SessionMembers();
  }

  List<Widget> buildMore() {
    return [];
  }
}

class SessionManager extends BaseSessionManager {
  Stream<List<Donation>> lastDonationsStream;
  SessionManager({Session baseSession, String uid})
      : super(baseSession, uid: uid);

  @override
  void initStreams() {
    lastDonationsStream =
        DatabaseService.getDonationsFromSession(baseSession.id, 10)
            .asBroadcastStream();
    membersStream = DatabaseService.getSessionMembers(baseSession.id, 100)
        .asBroadcastStream();
  }

  @override
  List<Widget> buildMore() {
    return [SessionLastDonationsTitle(), SessionLastDonations()];
  }

  Widget buildJoinButton() {
    return baseSession?.creatorId?.isNotEmpty ?? true
        ? Consumer<UserManager>(
            builder: (context, um, child) => um.uid == baseSession.creatorId
                ? SizedBox.shrink()
                : SessionJoinButton())
        : SessionJoinButton();
  }
}

class PreviewSessionManager extends BaseSessionManager {
  PreviewSession session;

  PreviewSessionManager(this.session, {String uid})
      : super(session, uid: uid, isPreview: true);

  @override
  void initStreams() {
    sessionStream = Stream.value(baseSession).asBroadcastStream();
    membersStream = Stream.value(<SessionMember>[]).asBroadcastStream();
  }

  @override
  Widget buildHeadingImage() {
    return Builder(builder: (context) {
      Color textColor =
          ThemeManager.of(context).correctColorFor(baseSession.secondaryColor);

      if (session.uploadableSession.image != null)
        return Image.file(
          session.uploadableSession.image,
          fit: BoxFit.cover,
        );
      if (baseSession.imgUrl != null) return super.buildHeadingImage();

      return SafeArea(
        bottom: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.photo,
                color: textColor,
              ),
              YMargin(12),
              Text(
                "Schließe die Vorschau um ein Titelbild zu wählen!",
                style: ThemeManager.of(context)
                    .textTheme
                    .correctColorFor(baseSession.secondaryColor)
                    .caption,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class CertifiedSessionManager extends BaseSessionManager {
  final String uid;
  CertifiedSession session;

  CertifiedSessionManager({this.session, this.uid})
      : super(session, isPreview: false);

  @override
  void initStreams() {
    membersStream = DatabaseService.getSessionMembers(baseSession.id, 100)
        .asBroadcastStream();
  }

  @override
  Widget buildHeadingImage() {
    return session.videoUrl != null && session.videoUrl.isNotEmpty
        ? SessionVideoHeading()
        : super.buildHeadingImage();
  }
}
