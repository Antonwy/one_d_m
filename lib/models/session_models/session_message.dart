import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SessionMessage {
  // from UserId, to SessionId
  final String? fromUid, toSid, message;
  final DateTime? createdAt;

  SessionMessage(
      {required this.fromUid,
      this.toSid,
      required this.message,
      this.createdAt});

  factory SessionMessage.fromDoc(DocumentSnapshot doc) {
    return SessionMessage(
        fromUid: doc[FROM_UID],
        message: doc[MESSAGE],
        createdAt: (doc[CREATED_AT] as Timestamp).toDate());
  }

  Map<String, dynamic> toMap() {
    return {FROM_UID: fromUid, MESSAGE: message, CREATED_AT: Timestamp.now()};
  }

  static List<SessionMessage> fromQuerySnapshot(QuerySnapshot qs) {
    return qs.docs.map((e) => SessionMessage.fromDoc(e)).toList();
  }

  static const String FROM_UID = "from_uid",
      TO_SID = "to_sid",
      MESSAGE = "message",
      CREATED_AT = "created_at";

  static List<SessionMessage> dummyData = [
    SessionMessage(
        fromUid: "rn0lkN9rkeXHWrHBizAuPOucK6y1",
        message: "Hey!",
        createdAt: DateTime.now()),
    SessionMessage(
        fromUid: "rn0lkN9rkeXHWrHBizAuPOucK6y1",
        message: "Wie gehts euch so?",
        createdAt: DateTime.now()),
    SessionMessage(
        fromUid: "3xfpRqwXDwMkeWorUX7Uep6gftd2",
        message: "Hey! Mir gehts gut!",
        createdAt: DateTime.now()),
    SessionMessage(
        fromUid: "3xfpRqwXDwMkeWorUX7Uep6gftd2",
        message: "Und dir?",
        createdAt: DateTime.now()),
    SessionMessage(
        fromUid: "AMBMUvvMmBXndbiahfbOQM6VNmH2",
        message: "Servus!",
        createdAt: DateTime.now()),
    SessionMessage(
        fromUid: "rn0lkN9rkeXHWrHBizAuPOucK6y1",
        message: "Alles gut hier!",
        createdAt: DateTime.now()),
  ];
}
