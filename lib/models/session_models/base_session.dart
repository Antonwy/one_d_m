import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/helper.dart';
import 'package:one_d_m/models/donation_unit.dart';
import 'package:one_d_m/models/session_models/certified_session.dart';
import 'package:one_d_m/models/session_models/session.dart';
import 'package:one_d_m/provider/sessions_manager.dart';

class BaseSession {
  final String id, name, creatorId, campaignId, description, imgUrl, blurHash;
  final int donationGoal, amount;
  final DateTime createdAt;
  final Color primaryColor, secondaryColor;
  final bool isCertified, reachedGoal;
  final DonationUnit donationUnit;

  BaseSession(
      {this.imgUrl,
      this.donationUnit = DonationUnit.defaultUnit,
      this.blurHash,
      this.amount,
      this.creatorId,
      this.id,
      this.name,
      this.donationGoal,
      this.createdAt,
      this.campaignId,
      this.description,
      this.primaryColor,
      this.secondaryColor,
      this.isCertified = true,
      this.reachedGoal = false});

  BaseSession.fromDoc(DocumentSnapshot doc)
      : creatorId = doc.data()[CREATOR_ID],
        id = doc.id,
        name = doc.data()[SESSION_NAME],
        createdAt = (doc.data()[CREATED_AT] as Timestamp).toDate(),
        campaignId = doc.data()[CAMPAIGN_ID],
        amount = doc.data()[AMOUNT] ?? 0,
        description = doc.data()[SESSION_DESCRIPTION] ?? "",
        imgUrl = doc.data()[IMG_URL],
        donationGoal = doc.data()[DONATION_GOAL] ?? 0,
        donationUnit = DonationUnit(),
        primaryColor = doc.data()[PRIMARY_COLOR] != null
            ? Helper.hexToColor(doc.data()[PRIMARY_COLOR])
            : ColorTheme.wildGreen,
        secondaryColor = doc.data()[SECONDARY_COLOR] != null
            ? Helper.hexToColor(doc.data()[SECONDARY_COLOR])
            : ColorTheme.darkblue,
        blurHash = doc.data()[BLUR_HASH],
        isCertified = doc.data()[IS_CERTIFIED] ?? true,
        reachedGoal = doc.data()[REACHED_GOAL] ?? false;

  BaseSession.fromJson(Map<String, dynamic> map)
      : id = map['id'],
        creatorId = map[CREATOR_ID],
        name = map[SESSION_NAME],
        createdAt = DateTime.tryParse(map[CREATED_AT]),
        campaignId = map[CAMPAIGN_ID],
        amount = map[AMOUNT],
        description = map[SESSION_DESCRIPTION],
        imgUrl = map[IMG_URL],
        donationGoal = map[DONATION_GOAL] ?? 0,
        donationUnit = DonationUnit.fromMap(map),
        primaryColor = map[PRIMARY_COLOR] != null
            ? Helper.hexToColor(map[PRIMARY_COLOR])
            : ColorTheme.wildGreen,
        secondaryColor = map[SECONDARY_COLOR] != null
            ? Helper.hexToColor(map[SECONDARY_COLOR])
            : ColorTheme.darkblue,
        blurHash = map[BLUR_HASH],
        isCertified = map[IS_CERTIFIED] ?? true,
        reachedGoal = map[REACHED_GOAL] ?? false;

  BaseSession.fromJsonWithDonationUnit(
      Map<String, dynamic> map, DonationUnit unit)
      : id = map['id'],
        creatorId = map[CREATOR_ID],
        name = map[SESSION_NAME],
        createdAt = DateTime.tryParse(map[CREATED_AT]),
        campaignId = map[CAMPAIGN_ID],
        amount = map[AMOUNT],
        description = map[SESSION_DESCRIPTION],
        imgUrl = map[IMG_URL],
        donationGoal = map[DONATION_GOAL] ?? 0,
        donationUnit = unit,
        primaryColor = map[PRIMARY_COLOR] != null
            ? Helper.hexToColor(map[PRIMARY_COLOR])
            : ColorTheme.wildGreen,
        secondaryColor = map[SECONDARY_COLOR] != null
            ? Helper.hexToColor(map[SECONDARY_COLOR])
            : ColorTheme.darkblue,
        blurHash = map[BLUR_HASH],
        isCertified = map[IS_CERTIFIED] ?? true,
        reachedGoal = map[REACHED_GOAL] ?? false;

  static List<BaseSession> fromQuerySnapshot(QuerySnapshot qs) {
    return qs.docs.map((doc) {
      return (doc.data()[IS_CERTIFIED] ?? true)
          ? CertifiedSession.fromDoc(doc)
          : Session.fromDoc(doc);
    }).toList();
  }

  static List<BaseSession> listFromJson(List<Map<String, dynamic>> list,
      [DonationUnit unit]) {
    return list
        .map((map) => unit == null
            ? BaseSession.fromJson(map)
            : BaseSession.fromJsonWithDonationUnit(map, unit))
        .toList();
  }

  BaseSessionManager manager(String uid) {
    return this.isCertified
        ? CertifiedSessionManager(session: this, uid: uid)
        : SessionManager(baseSession: this, uid: uid);
  }

  static const String CREATED_AT = "created_at",
      CREATOR_ID = "creator_id",
      CAMPAIGN_ID = "campaign_id",
      SESSION_DESCRIPTION = "description",
      ID = "id",
      SESSION_NAME = "name",
      END_DATE = "end_date",
      PRIMARY_COLOR = "primary_color",
      SECONDARY_COLOR = "secondary_color",
      DONATION_GOAL = "donation_goal",
      CAMPAIGN_IMG_URL = "campaign_image_url",
      CAMPAIGN_THUMBNAIL_URL = "campaign_thumbnail_url",
      CAMPAIGN_NAME = "campaign_title",
      AMOUNT = "amount",
      CAMPAIGN_SHORT_DESCRIPTION = "campaign_short_description",
      BLUR_HASH = "blur_hash",
      DONATION_GOAL_CURRENT = "donation_goal_current",
      DONATION_UNIT = "donation_unit",
      DONATION_UNIT_EFFECT = "donation_unit_effect",
      SORT_IMPORTANCE = "sort_importance",
      IS_CERTIFIED = "is_certified",
      REACHED_GOAL = "goal_reached",
      IMG_URL = "image_url";

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseSession && other.id == id;
  }

  @override
  String toString() {
    return 'BaseSession(blurHash: $blurHash, image_url: $imgUrl, createdAt: $createdAt, secondaryColor: $secondaryColor, reachedGoal: $reachedGoal, donationUnit: $donationUnit)';
  }
}
