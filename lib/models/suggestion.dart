import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/helper/helper.dart';
import 'package:one_d_m/provider/theme_manager.dart';

class Suggestion {
  final String title,
      subTitle,
      doneTitle,
      doneSubTitle,
      campaignId,
      campaignName,
      animationUrl;
  Color primaryColor, secondaryColor, textOnPrimary, textOnSecondary;
  final int amount, amountPerDonation;
  int donatedToday;
  final bool visible, onlyAdmins;

  Suggestion(
      {this.title,
      this.subTitle,
      this.doneTitle,
      this.doneSubTitle,
      this.campaignId,
      this.campaignName,
      this.animationUrl,
      this.amount = 1,
      this.amountPerDonation = 1,
      this.visible = false,
      this.onlyAdmins = false,
      this.donatedToday = 0,
      this.primaryColor,
      this.secondaryColor,
      this.textOnPrimary,
      this.textOnSecondary});

  factory Suggestion.fromDoc(DocumentSnapshot doc) {
    return Suggestion(
      title: doc.data()[TITLE],
      subTitle: doc.data()[SUBTITLE],
      doneTitle: doc.data()[DONE_TITLE],
      doneSubTitle: doc.data()[DONE_SUBTITLE],
      campaignId: doc.data()[CAMPAIGN_ID],
      campaignName: doc.data()[CAMPAIGN_NAME],
      animationUrl: doc.data()[ANIMATION_URL],
      amountPerDonation: doc.data()[AMOUNT_PER_DONATION],
      amount: doc.data()[AMOUNT],
      visible: doc.data()[VISIBLE] ?? false,
      onlyAdmins: doc.data()[ONLY_ADMINS] ?? false,
      primaryColor: doc.data()[PRIMARY_COLOR] != null
          ? Helper.hexToColor(doc.data()[PRIMARY_COLOR])
          : null,
      secondaryColor: doc.data()[SECONDARY_COLOR] != null
          ? Helper.hexToColor(doc.data()[SECONDARY_COLOR])
          : null,
      textOnPrimary: doc.data()[TEXT_ON_PRIMARY] != null
          ? Helper.hexToColor(doc.data()[TEXT_ON_PRIMARY])
          : null,
      textOnSecondary: doc.data()[TEXT_ON_SECONDARY] != null
          ? Helper.hexToColor(doc.data()[TEXT_ON_SECONDARY])
          : null,
    );
  }

  void setDefaultColors(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    if (primaryColor == null) this.primaryColor = _theme.colors.contrast;
    if (secondaryColor == null)
      this.secondaryColor = _theme.colors.contrast.withOpacity(.5);
    if (textOnPrimary == null)
      this.textOnPrimary = _theme.colors.textOnContrast;
    if (textOnSecondary == null)
      this.textOnSecondary = _theme.colors.textOnContrast;
  }

  bool get isDone => donatedToday >= (amount * amountPerDonation);

  static List<Suggestion> fromQuerySnapshot(QuerySnapshot qs) {
    return qs.docs.map((doc) => Suggestion.fromDoc(doc)).toList();
  }

  static const String TITLE = "title",
      SUBTITLE = "sub_title",
      DONE_TITLE = "done_title",
      DONE_SUBTITLE = "done_sub_title",
      CAMPAIGN_ID = "campaign_id",
      ANIMATION_URL = "animation_url",
      AMOUNT_PER_DONATION = "amount_per_donation",
      CAMPAIGN_NAME = "campaign_name",
      VISIBLE = "visible",
      ONLY_ADMINS = "only_admins",
      AMOUNT = "amount",
      PRIMARY_COLOR = "primary_color",
      SECONDARY_COLOR = "secondary_color",
      TEXT_ON_PRIMARY = "text_on_primary",
      TEXT_ON_SECONDARY = "text_on_secondary";

  @override
  String toString() {
    return "Suggestion: title: $title, subTitle: $subTitle, campaignName: $campaignName, amount: $amount, visible: $visible";
  }
}
