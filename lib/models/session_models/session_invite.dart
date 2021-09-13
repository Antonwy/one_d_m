import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:one_d_m/models/session_models/base_session.dart';

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
