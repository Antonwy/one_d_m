import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/api/stream_result.dart';
import 'package:one_d_m/components/video_or_image.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/components/sessions/session_goal.dart';
import 'package:one_d_m/components/sessions/session_join_button.dart';
import 'package:one_d_m/components/sessions/session_last_donations.dart';
import 'package:one_d_m/components/sessions/session_members.dart';
import 'package:one_d_m/helper/dynamic_link_manager.dart';
import 'package:one_d_m/helper/share_image.dart';
import 'package:one_d_m/helper/shareable.dart';
import 'package:one_d_m/models/donation_unit.dart';
import 'package:one_d_m/models/session_models/base_session.dart';
import 'package:one_d_m/models/session_models/preview_session.dart';
import 'package:one_d_m/models/session_models/session.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:one_d_m/views/sessions/session_page.dart';
import 'package:provider/provider.dart';
import 'package:social_share/social_share.dart';

abstract class BaseSessionManager extends ChangeNotifier with Shareable {
  BaseSession? baseSession;
  final bool isPreview;
  bool subscribed = false;
  final String? uid;
  late Stream<StreamResult<Session>> sessionStream;
  Session? session;
  bool? loadingMoreInfo = true, fromCache = true;

  BaseSessionManager(this.baseSession, {this.isPreview = false, this.uid}) {
    initData();
  }

  Future<void> initData();

  Future<void> delete() {
    return Api().sessions().delete(baseSession!.id!);
  }

  Future<void> share(BuildContext context) async {
    if ((baseSession?.name?.isEmpty ?? true) ||
        (baseSession!.imgUrl?.isEmpty ?? true)) return;

    SocialShare.shareOptions(await getShareUrl(context));
  }

  Widget buildHeading() {
    return SessionTitleImage();
  }

  Widget buildHeadingImage() {
    return VideoOrImage(
      imageUrl: baseSession!.imgUrl,
      videoUrl: session?.videoUrl,
      blurHash: baseSession!.blurHash,
    );
  }

  Widget buildTitle() {
    return SessionTitle();
  }

  String? campaignName() =>
      "${!loadingMoreInfo! ? session?.campaignTitle : "Lade Projekt..."}";

  Widget buildJoinButton() {
    return baseSession?.creatorId?.isNotEmpty ?? true
        ? Consumer<UserManager>(
            builder: (context, um, child) => um.uid == baseSession!.creatorId
                ? Container() // CreatePostButton()
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
    return [SessionLastDonationsTitle(), SessionLastDonations()];
  }

  Future<InstagramImages?> getShareImages(BuildContext? context) {
    return ShareImage.of(context).createSessionImageFromManager(this);
  }

  Future<String> getShareUrl(BuildContext? context) async {
    return (await DynamicLinkManager.of(context)
            .createSessionLink(baseSession!))
        .toString();
  }

  DonationUnit? get unit => session?.donationUnit ?? baseSession!.donationUnit;

  Future<void> leaveOrJoinSession(bool join, BuildContext context) async {
    try {
      if (join)
        await Api().sessions().subscribe(baseSession!.id);
      else
        await Api().sessions().unsubscribe(baseSession!.id);

      await context.read<FirebaseAnalytics>().logEvent(
          name: "${join ? 'Joined' : 'Left'} Session",
          parameters: {"session": baseSession!.id});
    } catch (e) {
      print("something went wrong subscribing!");
      return;
    }
    subscribed = join;
    notifyListeners();
  }
}

class SessionManager extends BaseSessionManager {
  SessionManager({BaseSession? baseSession, String? uid})
      : super(baseSession, uid: uid);

  @override
  Future<void> initData() async {
    sessionStream = baseSession is Session
        ? Stream.value(
            StreamResult(fromCache: false, data: baseSession as Session))
        : Api().sessions().streamGetOne(baseSession!.id);

    await for (StreamResult result in sessionStream) {
      session = result.data;
      fromCache = result.fromCache;
      print("CAMPAIGN IMAGE: ${session!.campaignImageUrl}");
      loadingMoreInfo = false;
      baseSession = session;
      subscribed = session!.subscribed;
      print(session!.campaignImageUrl);
      notifyListeners();
    }
  }
}

class CertifiedSessionManager extends SessionManager {
  final String? uid;

  CertifiedSessionManager({BaseSession? session, this.uid})
      : super(baseSession: session, uid: uid);
}

class PreviewSessionManager extends BaseSessionManager {
  PreviewSession previewSession;

  PreviewSessionManager(this.previewSession, {String? uid})
      : super(previewSession, uid: uid, isPreview: true);

  @override
  Future<void> initData() async {
    baseSession = previewSession;
  }

  @override
  String? campaignName() =>
      previewSession.uploadableSession!.campaign!.name ??
      "No Campaign selected";

  @override
  DonationUnit? get unit => previewSession.uploadableSession!.campaign!.unit;

  @override
  Widget buildHeadingImage() {
    return Builder(builder: (context) {
      Color? textColor = ThemeManager.of(context)
          .correctColorFor(baseSession!.secondaryColor!);

      if (previewSession.uploadableSession!.image != null)
        return Image.file(
          previewSession.uploadableSession!.image!,
          fit: BoxFit.cover,
        );
      if (baseSession!.imgUrl != null) return super.buildHeadingImage();

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
                    .correctColorFor(baseSession!.secondaryColor!)
                    .caption,
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  List<Widget> buildMore() {
    return [];
  }
}
