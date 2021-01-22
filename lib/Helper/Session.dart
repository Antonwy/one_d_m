import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';

import 'Campaign.dart';
import 'Helper.dart';
import 'User.dart';

class BaseSession {
  final String id, name, creatorId, campaignId, sessionDescription;
  final int amountPerUser;
  final DateTime createdAt, endDate;

  BaseSession(
      {this.creatorId,
      this.id,
      this.name,
      this.amountPerUser,
      this.createdAt,
      this.campaignId,
      this.sessionDescription,
      this.endDate});

  factory BaseSession.fromDoc(DocumentSnapshot doc) {
    return BaseSession(
      creatorId: doc.data()[CREATOR_ID],
      campaignId: doc.data()[CAMPAIGN_ID],
      id: doc.id,
      name: doc.data()[SESSION_NAME],
      amountPerUser: doc.data()[AMOUNT_PER_USER],
      createdAt: (doc.data()[CREATED_AT] as Timestamp).toDate(),
      endDate: doc.data()[END_DATE] == null
          ? null
          : (doc.data()[END_DATE] as Timestamp).toDate(),
      sessionDescription: doc.data()[SESSION_DESCRIPTION] ?? "",
    );
  }

  static List<BaseSession> fromQuerySnapshot(QuerySnapshot qs) {
    return qs.docs.map((doc) => BaseSession.fromDoc(doc)).toList();
  }

  static const String CREATED_AT = "created_at",
      CREATOR_ID = "creator_id",
      CAMPAIGN_ID = "campaign_id",
      SESSION_DESCRIPTION = "session_description",
      ID = "id",
      SESSION_NAME = "session_name",
      END_DATE = "end_date",
      AMOUNT_PER_USER = "amount_per_user";
}

class Session extends BaseSession {
  final String campaignImgUrl, campaignName, campaignShortDescription, imgUrl;
  final int currentAmount, memberCount;
  final Color primaryColor, secondaryColor;

  Session(
      {String id,
      String name,
      String creatorId,
      int amountPerUser,
      DateTime createdAt,
      DateTime endDate,
      String campaignId,
      String sessionDescription,
      this.imgUrl,
      this.currentAmount,
      this.memberCount,
      this.campaignImgUrl,
      this.campaignName,
      this.campaignShortDescription,
      this.primaryColor,
      this.secondaryColor})
      : super(
            id: id,
            name: name,
            amountPerUser: amountPerUser,
            creatorId: creatorId,
            createdAt: createdAt,
            campaignId: campaignId,
            endDate: endDate,
            sessionDescription: sessionDescription);

  factory Session.fromDoc(DocumentSnapshot doc) {
    if (!doc.exists) return Session();
    return Session(
      creatorId: doc.data()[BaseSession.CREATOR_ID],
      id: doc.id,
      name: doc.data()[BaseSession.SESSION_NAME],
      amountPerUser: doc.data()[BaseSession.AMOUNT_PER_USER],
      createdAt: (doc.data()[BaseSession.CREATED_AT] as Timestamp).toDate(),
      endDate: doc.data()[BaseSession.END_DATE] == null
          ? null
          : (doc.data()[BaseSession.END_DATE] as Timestamp).toDate(),
      campaignId: doc.data()[BaseSession.CAMPAIGN_ID],
      campaignName: doc.data()[CAMPAIGN_NAME],
      campaignImgUrl: doc.data()[CAMPAIGN_IMG_URL],
      currentAmount: doc.data()[CURRENT_AMOUNT],
      memberCount: doc.data()[MEMBER_COUNT] ?? 0,
      campaignShortDescription: doc.data()[CAMPAIGN_SHORT_DESCRIPTION],
      sessionDescription: doc.data()[BaseSession.SESSION_DESCRIPTION] ?? "",
      imgUrl: doc.data()[IMG_URL],
      primaryColor: doc.data()[PRIMARY_COLOR] != null
          ? Helper.hexToColor(doc.data()[PRIMARY_COLOR])
          : ColorTheme.wildGreen,
      secondaryColor: doc.data()[SECONDARY_COLOR] != null
          ? Helper.hexToColor(doc.data()[SECONDARY_COLOR])
          : ColorTheme.darkblue,
    );
  }

  static List<Session> fromQuerySnapshot(QuerySnapshot qs) {
    return qs.docs.map((doc) {
      Session.fromDoc(doc);
    }).toList();
  }

  static const CAMPAIGN_IMG_URL = "campaign_img_url",
      CAMPAIGN_NAME = "campaign_name",
      CURRENT_AMOUNT = "current_amount",
      MEMBER_COUNT = "member_count",
      CAMPAIGN_SHORT_DESCRIPTION = "campaign_short_description",
      PRIMARY_COLOR = "primary_color",
      SECONDARY_COLOR = "secondary_color",
      IMG_URL = "img_url";
}

class UploadableSession {
  final Campaign campaign;
  final List<User> members;
  final String sessionName, sessionDescription;
  final int amountPerUser;

  UploadableSession(
      {this.sessionName,
      this.sessionDescription,
      this.amountPerUser,
      this.campaign,
      this.members});

  Map<String, dynamic> toMap() {
    return {
      CAMPAIGN: campaign.toMap(),
      MEMBERS: members.map((u) => u.userInfoToMap()).toList(),
      BaseSession.SESSION_NAME: sessionName,
      BaseSession.AMOUNT_PER_USER: amountPerUser,
      BaseSession.SESSION_DESCRIPTION: sessionDescription
    };
  }

  @override
  String toString() {
    return "Campaign: $campaign, Members: $members, SessionName: $sessionName, AmountPerMember: $amountPerUser";
  }

  static const String MEMBERS = "members", CAMPAIGN = "campaign";
}

class SessionInvite {
  final String sessionCreatorId, sessionId, sessionName, sessionDescription;
  final int amountPerUser;

  SessionInvite(
      {this.sessionCreatorId,
      this.sessionId,
      this.sessionName,
      this.sessionDescription,
      this.amountPerUser});

  factory SessionInvite.fromDoc(DocumentSnapshot doc) {
    return SessionInvite(
        sessionCreatorId: doc.data()[SESSION_CREATOR_ID],
        sessionId: doc.data()[ID],
        sessionName: doc.data()[SESSION_NAME],
        sessionDescription: doc.data()[BaseSession.SESSION_DESCRIPTION] ?? "",
        amountPerUser: doc.data()[BaseSession.AMOUNT_PER_USER]);
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
