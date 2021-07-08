import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/ShareImage.dart';

import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/Provider/SessionManager.dart';

import 'Campaign.dart';
import 'Helper.dart';
import 'User.dart';

abstract class BaseSession implements Comparable<BaseSession> {
  final String id,
      name,
      creatorId,
      campaignId,
      sessionDescription,
      campaignImgUrl,
      campaignName,
      campaignShortDescription,
      imgUrl,
      donationUnit,
      donationUnitEffect,
      blurHash;
  final int donationGoal,
      currentAmount,
      memberCount,
      donationGoalCurrent,
      sortImportance;
  final DateTime createdAt;
  final Color primaryColor, secondaryColor;
  final bool isCertified, reachedGoal;

  BaseSession(
      {this.campaignImgUrl,
      this.campaignName,
      this.campaignShortDescription,
      this.imgUrl,
      this.donationUnit = "DV",
      this.donationUnitEffect = "gespendet",
      this.blurHash,
      this.currentAmount,
      this.memberCount,
      this.donationGoalCurrent,
      this.creatorId,
      this.id,
      this.name,
      this.donationGoal,
      this.createdAt,
      this.campaignId,
      this.sessionDescription,
      this.primaryColor,
      this.secondaryColor,
      this.isCertified = true,
      this.sortImportance = 0,
      this.reachedGoal = false});

  BaseSession.fromDoc(DocumentSnapshot doc)
      : creatorId = doc.data()[CREATOR_ID],
        id = doc.id,
        name = doc.data()[SESSION_NAME],
        createdAt = (doc.data()[CREATED_AT] as Timestamp).toDate(),
        campaignId = doc.data()[CAMPAIGN_ID],
        campaignName = doc.data()[CAMPAIGN_NAME],
        campaignImgUrl = doc.data()[CAMPAIGN_IMG_URL],
        currentAmount = doc.data()[CURRENT_AMOUNT],
        memberCount = doc.data()[MEMBER_COUNT] ?? 0,
        campaignShortDescription = doc.data()[CAMPAIGN_SHORT_DESCRIPTION],
        sessionDescription = doc.data()[SESSION_DESCRIPTION] ?? "",
        imgUrl = doc.data()[IMG_URL],
        donationGoal = doc.data()[DONATION_GOAL] ?? 0,
        donationGoalCurrent = doc.data()[DONATION_GOAL_CURRENT] ?? 0,
        donationUnit = doc.data()[DONATION_UNIT] ?? "DV",
        donationUnitEffect = doc.data()[DONATION_UNIT_EFFECT] ?? "gespendet",
        primaryColor = doc.data()[PRIMARY_COLOR] != null
            ? Helper.hexToColor(doc.data()[PRIMARY_COLOR])
            : ColorTheme.wildGreen,
        secondaryColor = doc.data()[SECONDARY_COLOR] != null
            ? Helper.hexToColor(doc.data()[SECONDARY_COLOR])
            : ColorTheme.darkblue,
        blurHash = doc.data()[BLUR_HASH],
        isCertified = doc.data()[IS_CERTIFIED] ?? true,
        sortImportance = doc.data()[SORT_IMPORTANCE],
        reachedGoal = doc.data()[REACHED_GOAL] ?? false;

  static List<BaseSession> fromQuerySnapshot(QuerySnapshot qs) {
    return qs.docs.map((doc) {
      return (doc.data()[IS_CERTIFIED] ?? true)
          ? CertifiedSession.fromDoc(doc)
          : Session.fromDoc(doc);
    }).toList();
  }

  static const String CREATED_AT = "created_at",
      CREATOR_ID = "creator_id",
      CAMPAIGN_ID = "campaign_id",
      SESSION_DESCRIPTION = "session_description",
      ID = "id",
      SESSION_NAME = "session_name",
      END_DATE = "end_date",
      PRIMARY_COLOR = "primary_color",
      SECONDARY_COLOR = "secondary_color",
      DONATION_GOAL = "donation_goal",
      CAMPAIGN_IMG_URL = "campaign_img_url",
      CAMPAIGN_NAME = "campaign_name",
      CURRENT_AMOUNT = "current_amount",
      MEMBER_COUNT = "member_count",
      CAMPAIGN_SHORT_DESCRIPTION = "campaign_short_description",
      BLUR_HASH = "blur_hash",
      DONATION_GOAL_CURRENT = "donation_goal_current",
      DONATION_UNIT = "donation_unit",
      DONATION_UNIT_EFFECT = "donation_unit_effect",
      SORT_IMPORTANCE = "sort_importance",
      IS_CERTIFIED = "is_certified",
      REACHED_GOAL = "reached_goal",
      IMG_URL = "img_url";

  BaseSessionManager manager(String uid);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseSession && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  int compareTo(BaseSession other) {
    if (this.reachedGoal && other.reachedGoal) {
      int thisDonDiff = this.donationGoal - this.donationGoalCurrent;
      int otherDonDiff = other.donationGoal - other.donationGoalCurrent;

      return otherDonDiff.compareTo(thisDonDiff);
    }

    if (this.reachedGoal) return 1;
    if (other.reachedGoal) return -1;

    if (this.isCertified && other.isCertified) {
      int sCompare = other.sortImportance.compareTo(this.sortImportance);
      return sCompare == 0 ? other.name.compareTo(this.name) : sCompare;
    }
    if (this.isCertified) return -1;
    if (other.isCertified) return 1;
    int sCompare = other.sortImportance.compareTo(this.sortImportance);
    return sCompare == 0 ? this.name.compareTo(other.name) : sCompare;
  }
}

class Session extends BaseSession {
  Session.fromDoc(DocumentSnapshot doc) : super.fromDoc(doc);

  @override
  BaseSessionManager manager(String uid) =>
      SessionManager(baseSession: this, uid: uid);
}

class CertifiedSession extends BaseSession {
  final String videoUrl;

  CertifiedSession.fromDoc(DocumentSnapshot doc)
      : videoUrl = doc.data()[VIDEO_URL],
        super.fromDoc(doc);

  static const String VIDEO_URL = "video_url";

  @override
  BaseSessionManager manager(String uid) =>
      CertifiedSessionManager(session: this, uid: uid);
}

class PreviewSession extends BaseSession {
  final UploadableSession uploadableSession;

  PreviewSession(
      {String id,
      String campaignId,
      String name,
      int donationGoal,
      int donationGoalCurrent,
      String donationUnit,
      String donationUnitEffect,
      String sessionDescription,
      String creatorId,
      Color secondaryColor,
      Color primaryColor,
      String imgUrl,
      this.uploadableSession})
      : super(
            id: id,
            campaignId: campaignId,
            name: name,
            donationGoal: donationGoal,
            donationGoalCurrent: donationGoalCurrent,
            donationUnit: donationUnit,
            donationUnitEffect: donationUnitEffect,
            sessionDescription: sessionDescription,
            creatorId: creatorId,
            imgUrl: imgUrl,
            secondaryColor: secondaryColor,
            primaryColor: primaryColor);

  @override
  BaseSessionManager manager(String uid) =>
      PreviewSessionManager(this, uid: uid);
}

class UploadableSession {
  final Campaign campaign;
  final List<User> members;
  final String sessionName, sessionDescription, creatorId;
  String imgUrl, id;
  final int donationGoal;
  final File image;
  final Color primaryColor, secondaryColor;

  UploadableSession({
    this.id,
    this.sessionName,
    this.sessionDescription,
    this.donationGoal,
    this.campaign,
    this.members,
    this.image,
    this.imgUrl,
    this.primaryColor,
    this.secondaryColor,
    this.creatorId,
  });

  Map<String, dynamic> toMap() {
    return {
      BaseSession.CAMPAIGN_ID: campaign.id,
      BaseSession.PRIMARY_COLOR: Helper.colorToHex(primaryColor),
      BaseSession.SECONDARY_COLOR: Helper.colorToHex(secondaryColor),
      BaseSession.SESSION_NAME: sessionName,
      BaseSession.DONATION_GOAL: donationGoal,
      BaseSession.SESSION_DESCRIPTION: sessionDescription,
      BaseSession.CREATED_AT: Timestamp.now(),
      BaseSession.CREATOR_ID: creatorId,
      BaseSession.CAMPAIGN_NAME: campaign.name.trim(),
      BaseSession.CURRENT_AMOUNT: 0,
      BaseSession.MEMBER_COUNT: 1,
      BaseSession.IMG_URL: imgUrl,
      BaseSession.IS_CERTIFIED: false,
      BaseSession.SORT_IMPORTANCE: 0,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    Map<String, dynamic> map = {
      BaseSession.PRIMARY_COLOR: Helper.colorToHex(primaryColor),
      BaseSession.SECONDARY_COLOR: Helper.colorToHex(secondaryColor),
      BaseSession.SESSION_NAME: sessionName,
      BaseSession.DONATION_GOAL: donationGoal,
      BaseSession.SESSION_DESCRIPTION: sessionDescription,
    };

    if (imgUrl != null) map[BaseSession.IMG_URL] = imgUrl;
    return map;
  }

  BaseSession get baseSession => PreviewSession(
      id: "no-id",
      campaignId: campaign.id,
      name: sessionName,
      donationGoal: donationGoal,
      donationGoalCurrent: 0,
      donationUnit: "DV",
      donationUnitEffect: "test",
      sessionDescription: sessionDescription,
      creatorId: creatorId,
      secondaryColor: secondaryColor,
      primaryColor: primaryColor);

  @override
  String toString() {
    return "Campaign: $campaign, Members: $members, SessionName: $sessionName, AmountPerMember: $donationGoal";
  }
}

class SessionInvite {
  final String sessionCreatorId, sessionId, sessionName, sessionDescription;
  final int donationGoal;

  SessionInvite(
      {this.sessionCreatorId,
      this.sessionId,
      this.sessionName,
      this.sessionDescription,
      this.donationGoal});

  factory SessionInvite.fromDoc(DocumentSnapshot doc) {
    return SessionInvite(
        sessionCreatorId: doc.data()[SESSION_CREATOR_ID],
        sessionId: doc.data()[ID],
        sessionName: doc.data()[SESSION_NAME],
        sessionDescription: doc.data()[BaseSession.SESSION_DESCRIPTION] ?? "",
        donationGoal: doc.data()[BaseSession.DONATION_GOAL]);
  }

  static List<SessionInvite> fromQuerySnapshot(QuerySnapshot qs) {
    return qs.docs.map((doc) => SessionInvite.fromDoc(doc)).toList();
  }

  Map<String, dynamic> toMap() {
    return {
      ID: sessionId,
      SESSION_CREATOR_ID: sessionCreatorId,
      SESSION_NAME: sessionName
    };
  }

  static const String SESSION_CREATOR_ID = "session_creator",
      ID = "id",
      SESSION_NAME = "session_name";

  @override
  String toString() {
    return "CreatorId: $sessionCreatorId, id: $sessionId, name: $sessionName";
  }
}

class SessionMember {
  final String userId;
  final int donationAmount;

  SessionMember({this.userId, this.donationAmount});

  factory SessionMember.fromDoc(DocumentSnapshot doc) => SessionMember(
      userId: doc.data()[ID], donationAmount: doc.data()[DONATION_AMOUNT] ?? 0);

  static List<SessionMember> fromQuerySnapshot(QuerySnapshot qs) {
    return qs.docs.map((doc) => SessionMember.fromDoc(doc)).toList();
  }

  static const String ID = "id", DONATION_AMOUNT = "donation_amount";
}

mixin Shareable {
  Future<String> getShareUrl(BuildContext context);
  Future<InstagramImages> getShareImages(BuildContext context);
}
