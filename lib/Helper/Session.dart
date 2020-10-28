import 'package:cloud_firestore/cloud_firestore.dart';

import 'Campaign.dart';
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
      creatorId: doc[CREATOR_ID],
      campaignId: doc[CAMPAIGN_ID],
      id: doc.documentID,
      name: doc[SESSION_NAME],
      amountPerUser: doc[AMOUNT_PER_USER],
      createdAt: (doc[CREATED_AT] as Timestamp).toDate(),
      endDate: (doc[END_DATE] as Timestamp).toDate(),
      sessionDescription: doc[SESSION_DESCRIPTION] ?? "",
    );
  }

  static List<BaseSession> fromQuerySnapshot(QuerySnapshot qs) {
    return qs.documents.map((doc) => BaseSession.fromDoc(doc)).toList();
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
  final String campaignImgUrl, campaignName, campaignShortDescription;

  Session(
      {String id,
      String name,
      String creatorId,
      int amountPerUser,
      DateTime createdAt,
      DateTime endDate,
      String campaignId,
      String sessionDescription,
      this.campaignImgUrl,
      this.campaignName,
      this.campaignShortDescription})
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
    return Session(
        creatorId: doc[BaseSession.CREATOR_ID],
        id: doc.documentID,
        name: doc[BaseSession.SESSION_NAME],
        amountPerUser: doc[BaseSession.AMOUNT_PER_USER],
        createdAt: (doc[BaseSession.CREATED_AT] as Timestamp).toDate(),
        endDate: (doc[BaseSession.END_DATE] as Timestamp).toDate(),
        campaignId: doc[BaseSession.CAMPAIGN_ID],
        campaignName: doc[CAMPAIGN_NAME],
        campaignImgUrl: doc[CAMPAIGN_IMG_URL],
        campaignShortDescription: doc[CAMPAIGN_SHORT_DESCRIPTION],
        sessionDescription: doc[BaseSession.SESSION_DESCRIPTION] ?? "");
  }

  static const CAMPAIGN_IMG_URL = "campaign_img_url",
      CAMPAIGN_NAME = "campaign_name",
      CAMPAIGN_SHORT_DESCRIPTION = "campaign_short_description";
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
        sessionCreatorId: doc[SESSION_CREATOR_ID],
        sessionId: doc[ID],
        sessionName: doc[SESSION_NAME],
        sessionDescription: doc[BaseSession.SESSION_DESCRIPTION] ?? "",
        amountPerUser: doc[BaseSession.AMOUNT_PER_USER]);
  }

  static List<SessionInvite> fromQuerySnapshot(QuerySnapshot qs) {
    return qs.documents.map((doc) => SessionInvite.fromDoc(doc)).toList();
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

  factory SessionMember.fromDoc(DocumentSnapshot doc) =>
      SessionMember(userId: doc[ID], donationAmount: doc[DONATION_AMOUNT] ?? 0);

  static List<SessionMember> fromQuerySnapshot(QuerySnapshot qs) {
    return qs.documents.map((doc) => SessionMember.fromDoc(doc)).toList();
  }

  static const String ID = "id", DONATION_AMOUNT = "donation_amount";
}
