import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart' as fireAuth;
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/models/campaign_models/campaign.dart';
import 'package:one_d_m/models/donation.dart';
import 'package:one_d_m/models/session_models/base_session.dart';
import 'package:one_d_m/models/session_models/certified_session.dart';
import 'package:one_d_m/models/session_models/session.dart';
import 'package:one_d_m/models/user.dart';
import 'package:one_d_m/models/user_account.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:one_d_m/views/campaigns/campaign_page.dart';
import 'package:one_d_m/views/sessions/session_page.dart';
import 'package:one_d_m/views/users/find_friends_page.dart';
import 'package:one_d_m/views/users/user_page.dart';
import 'package:provider/provider.dart';

import 'database_service.dart';

class DynamicLinkManager {
  final BuildContext? context;

  DynamicLinkManager(this.context);

  factory DynamicLinkManager.of(BuildContext? context) =>
      DynamicLinkManager(context);

  Future<void> initialize() async {
    print("INIT DEEPLINKS");
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData? dynamicLink) async {
      final Uri? deepLink = dynamicLink?.link;

      print(deepLink);
      if (deepLink != null) {
        _handleUri(deepLink, context: context);
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;
    print(deepLink);

    if (deepLink != null) {
      _handleUri(deepLink, context: context);
    }
  }

  Future<Uri> createCampaignLink(Campaign campaign, {bool short = true}) async {
    await context!.read<FirebaseAnalytics>().logShare(
        contentType: "Share Campaign",
        itemId: campaign.name!,
        method: "normal");
    return createLink(
        title: 'Schau dir das Projekt "${campaign.name}" auf ODM an!',
        description:
            'Komm auf die One Dollar Movement App um das Projekt "${campaign.name}" zu unterstützen!',
        imageUrl: campaign.thumbnailUrl ?? campaign.imgUrl,
        link:
            'https://one-dollar-movement.com/?${Donation.CAMPAIGNID}=${campaign.id}',
        short: short);
  }

  Future<Uri> createSessionLink(BaseSession session,
      {bool short = true}) async {
    await context!.read<FirebaseAnalytics>().logShare(
        contentType: "Share CertifiedSession",
        itemId: session.name!,
        method: "normal");
    return createLink(
        title: 'Schau dir ${session.name} auf ODM an!',
        description:
            'Komm auf die One Dollar Movement App um ${session.name} zu unterstützen!',
        imageUrl: session.imgUrl,
        link:
            'https://one-dollar-movement.com/?${Donation.SESSION_ID}=${session.id}',
        short: short);
  }

  Future<Uri> createUserLink(User user, {bool short = true}) async {
    await context!.read<FirebaseAnalytics>().logShare(
        contentType: "Share User", itemId: user.name, method: "normal");
    return createLink(
        title: 'Schau dir ${user.name}\'s auf ODM Profil an!',
        description:
            "Komm auf die One Dollar Movement App um ${user.name}'s Profil anzusehen!",
        imageUrl: user.thumbnailUrl ?? user.imgUrl,
        link: 'https://one-dollar-movement.com/?${Donation.USERID}=${user.id}',
        short: short);
  }

  static Future<Uri> createLink(
      {String? title,
      String? description,
      String? imageUrl,
      required String link,
      required bool short}) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: 'https://odm.page.link',
        link: Uri.parse(link),
        androidParameters: AndroidParameters(
          packageName: 'com.odm.onedollarmovement',
          minimumVersion: 114,
        ),
        iosParameters: IosParameters(
          bundleId: 'com.odm.onedollarmovement',
          minimumVersion: '1.0.25',
          appStoreId: '1523996816',
        ),
        socialMetaTagParameters: SocialMetaTagParameters(
            title: title,
            description: description,
            imageUrl: imageUrl == null ? null : Uri.parse(imageUrl)));

    return (short
        ? (await parameters.buildShortLink()).shortUrl
        : parameters.buildUrl()) as FutureOr<Uri>;
  }
}

void _handleUri(Uri deepLink, {BuildContext? context}) async {
  Map<String, dynamic> params = deepLink.queryParameters;
  print(params);

  UserManager um = context!.read<UserManager>();

  if (params.containsKey("oobCode")) {
    print("VERIFY EMAIL DEEPLINK!");
    var actionCode = params["oobCode"];
    fireAuth.FirebaseAuth auth = um.auth!;

    try {
      await auth.checkActionCode(actionCode);
      await auth.applyActionCode(actionCode);

      // If successful, reload the user:
      await um.fireUser!.reload();
      um.fireUser = um.auth!.currentUser;

      if (um.fireUser?.emailVerified ?? false) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FindFriendsPage(
                      afterRegister: true,
                    )));
      }
    } on fireAuth.FirebaseAuthException catch (e) {
      if (e.code == 'invalid-action-code') {
        print('The code is invalid.');
      }
    }
  }
  if (um.status != Status.Authenticated) return;

  if (params.containsKey(Donation.CAMPAIGNID)) {
    String? _campaignId = params[Donation.CAMPAIGNID];
    print("PUSHING TO CAMPAIGN: $_campaignId");
    try {
      Campaign? campaign = await Api().campaigns().getOne(_campaignId);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CampaignPage(campaign!)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Das Projekt wurde nicht gefunden!")));
      print(e);
    }
    return;
  }

  if (params.containsKey(Donation.SESSION_ID)) {
    String? _sessionId = params[Donation.SESSION_ID];
    print("PUSHING TO SESSION: $_sessionId");
    try {
      Session? session = await Api().sessions().getOne(_sessionId);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SessionPage(session)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Die Session wurde nicht gefunden!")));
      print(e);
    }
    return;
  }

  if (params.containsKey(Donation.USERID)) {
    String? _userId = params[Donation.USERID];
    print("PUSHING TO USER: $_userId");
    try {
      User? user = await Api().account().getOne(_userId);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserPage(user!)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Der Nutzer wurde nicht gefunden!")));
      print(e);
    }
    return;
  }
}
