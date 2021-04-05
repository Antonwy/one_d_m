import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Pages/CertifiedSessionPage.dart';
import 'package:one_d_m/Pages/NewCampaignPage.dart';
import 'package:one_d_m/Pages/UserPage.dart';
import 'package:provider/provider.dart';

import 'Campaign.dart';
import 'DatabaseService.dart';
import 'Donation.dart';
import 'User.dart';
import 'UserManager.dart';

class DynamicLinkManager {
  static void initialize(BuildContext context) async {
    print("INIT DEEPLINKS");
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      if (context.read<UserManager>().status != Status.Authenticated) return;
      final Uri deepLink = dynamicLink?.link;
      print("TEST DEEPLINK");
      print(deepLink);
      if (deepLink != null) {
        Map<String, dynamic> params = deepLink.queryParameters;
        print(params);
        if (params.containsKey(Donation.CAMPAIGNID)) {
          String _campaignId = params[Donation.CAMPAIGNID];
          print("PUSHING TO CAMPAIGN: $_campaignId");
          try {
            Campaign campaign = await DatabaseService.getCampaign(_campaignId);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NewCampaignPage(campaign)),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Das Projekt wurde nicht gefunden!")));
            print(e);
          }
          return;
        }

        if (params.containsKey(Donation.SESSION_ID)) {
          String _sessionId = params[Donation.SESSION_ID];
          print("PUSHING TO SESSION: $_sessionId");
          try {
            Session session =
                await DatabaseService.getSessionFuture(_sessionId);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CertifiedSessionPage(session: session)),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Die Session wurde nicht gefunden!")));
            print(e);
          }
          return;
        }

        if (params.containsKey(Donation.USERID)) {
          String _userId = params[Donation.USERID];
          print("PUSHING TO USER: $_userId");
          try {
            User user = await DatabaseService.getUser(_userId);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserPage(user)),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Der Nutzer wurde nicht gefunden!")));
            print(e);
          }
          return;
        }
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    // final PendingDynamicLinkData data =
    //     await FirebaseDynamicLinks.instance.getInitialLink();
    // final Uri deepLink = data?.link;
    // print(deepLink);

    // if (deepLink != null) {
    //   // Navigator.pushNamed(context, deepLink.path);
    // }
  }

  static Future<Uri> createCampaignLink(Campaign campaign,
      {bool short = true}) async {
    return createLink(
        title: 'Schau dir das Projekt "${campaign.name}" an!',
        description:
            'Komm auf ODM um das Projekt "${campaign.name}" zu unterstützen!',
        imageUrl: campaign.thumbnailUrl ?? campaign.imgUrl,
        link:
            'https://one-dollar-movement.com/?${Donation.CAMPAIGNID}=${campaign.id}',
        short: short);
  }

  static Future<Uri> createSessionLink(Session session,
      {bool short = true}) async {
    return createLink(
        title: 'Schau dir ${session.name} an!',
        description: 'Komm auf ODM um ${session.name} zu unterstützen!',
        imageUrl: session.imgUrl,
        link:
            'https://one-dollar-movement.com/?${Donation.SESSION_ID}=${session.id}',
        short: short);
  }

  static Future<Uri> createUserLink(User user, {bool short = true}) async {
    return createLink(
        title: 'Schau dir ${user.name}\'s Profil an!',
        description: "Komm auf ODM um ${user.name}'s Profil anzusehen!",
        imageUrl: user?.thumbnailUrl ?? user?.imgUrl,
        link: 'https://one-dollar-movement.com/?${Donation.USERID}=${user.id}',
        short: short);
  }

  static Future<Uri> createLink(
      {String title,
      String description,
      String imageUrl,
      @required String link,
      @required bool short}) async {
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

    return short
        ? (await parameters.buildShortLink()).shortUrl
        : parameters.buildUrl();
  }
}
