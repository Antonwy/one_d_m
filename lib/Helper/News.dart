import 'package:cloud_firestore/cloud_firestore.dart';

class News {
  static final String CAMPAIGNID = "campaign_id",
      CAMPAIGNNAME = "campaign_name",
      ORGANISATION_ID = "organisation_id",
      USERID = "user_id",
      TITLE = "title",
      TEXT = "text",
      SHORTTEXT = "short_text",
      CREATEDAT = "created_at",
      CAMPAIGNIMGURL = "campaign_img_url",
      IMAGEURL = "image_url",
      SESSION_ID = "session_id",
      VIDEO_URL = "video_url";

  String campaignId,
      userId,
      organisationId,
      campaignName,
      campaignImgUrl,
      title,
      text,
      shortText,
      imageUrl,
      videoUrl,
      id,
      sessionId;
  DateTime createdAt;

  News({
    this.campaignId,
    this.userId,
    this.id,
    this.organisationId,
    this.title,
    this.campaignImgUrl,
    this.text,
    this.shortText,
    this.createdAt,
    this.campaignName,
    this.imageUrl,
    this.videoUrl,
    this.sessionId,
  });

  Map<String, dynamic> toMap() {
    return {
      CAMPAIGNID: campaignId,
      CAMPAIGNNAME: campaignName,
      ORGANISATION_ID: organisationId,
      TITLE: title,
      TEXT: text,
      SHORTTEXT: shortText,
      IMAGEURL: imageUrl,
      VIDEO_URL: videoUrl,
      CAMPAIGNIMGURL: campaignImgUrl,
      CREATEDAT: Timestamp.now(),
      SESSION_ID: sessionId,
      USERID: userId
    };
  }

  static News fromSnapshot(DocumentSnapshot snapshot) {
    return News(
      id: snapshot.id,
      campaignId: snapshot.data()[CAMPAIGNID],
      title: snapshot.data()[TITLE],
      text: snapshot.data()[TEXT],
      shortText: snapshot.data()[SHORTTEXT],
      campaignName: snapshot.data()[CAMPAIGNNAME],
      campaignImgUrl: snapshot.data()[CAMPAIGNIMGURL],
      sessionId: snapshot.data()[SESSION_ID],
      imageUrl: snapshot.data()[IMAGEURL],
      videoUrl: snapshot.data()[VIDEO_URL],
      userId: snapshot.data()[USERID],
      createdAt: (snapshot.data()[CREATEDAT] as Timestamp).toDate(),
    );
  }

  static List<News> listFromSnapshot(List<DocumentSnapshot> snapshot) {
    return snapshot.map(News.fromSnapshot).toList();
  }
}
