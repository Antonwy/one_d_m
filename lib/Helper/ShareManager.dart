import 'dart:io';

import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/ShareImage.dart';
import 'package:social_share/social_share.dart';

import 'package:one_d_m/Helper/Session.dart';

class ShareItem {
  final Shareable shareable;
  final BuildContext context;
  final String text;
  final List<String> hashtags;

  ShareItem({this.shareable, this.context, this.text, this.hashtags});
}

class ShareManager {
  final ShareItem item;

  ShareManager.of(this.item);

  Future<void> share() async {
    return SocialShare.shareOptions(
        await item.shareable.getShareUrl(item.context));
  }

  Future<void> shareFromType(SocialMediaType type) {
    switch (type) {
      case SocialMediaType.instagram:
        return shareOnInstagram();
      case SocialMediaType.whatsapp:
        return shareOnWhatsApp();
      case SocialMediaType.telegram:
        return shareOnTelegram();
      case SocialMediaType.twitter:
        return shareOnTwitter();
      case SocialMediaType.twitter:
        return shareOnTwitter();
      case SocialMediaType.sms:
        return shareWithSms();
      case SocialMediaType.clipboard:
        return copyToClipboard();
      case SocialMediaType.other:
      default:
        return share();
    }
  }

  Future<void> shareOnInstagram() async {
    InstagramImages images = await item.shareable.getShareImages(item.context);
    return SocialShare.shareInstagramStory(images.foreground.path,
        backgroundTopColor: "#ffffff",
        backgroundBottomColor: "#000000",
        backgroundImagePath: images.background.path,
        attributionURL:
            (await item.shareable.getShareUrl(item.context)).toString());
  }

  Future<void> shareOnWhatsApp() async {
    return SocialShare.shareWhatsapp(
        await item.shareable.getShareUrl(item.context));
  }

  Future<void> shareOnTelegram() async {
    return SocialShare.shareTelegram(
        await item.shareable.getShareUrl(item.context));
  }

  Future<void> shareOnTwitter() async {
    return SocialShare.shareTwitter(item.text,
        url: await item.shareable.getShareUrl(item.context),
        hashtags: item.hashtags,
        trailingText: "");
  }

  Future<void> shareWithSms() async {
    return SocialShare.shareSms(item.text,
        url: await item.shareable.getShareUrl(item.context));
  }

  Future<void> copyToClipboard() async {
    String url = await item.shareable.getShareUrl(item.context);
    await SocialShare.copyToClipboard(url);
    print(url);
    ScaffoldMessenger.of(item.context)
        .showSnackBar(SnackBar(content: Text("Link kopiert!")));
  }
}

enum SocialMediaType {
  instagram,
  whatsapp,
  telegram,
  twitter,
  clipboard,
  sms,
  other
}
