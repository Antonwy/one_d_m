import 'package:cloud_firestore/cloud_firestore.dart';

class News {
  static const String CAMPAIGNID = "campaign_id",
      CAMPAIGNNAME = "campaign_name",
      ORGANISATION_ID = "organisation_id",
      USERID = "user_id",
      TITLE = "title",
      TEXT = "text",
      SHORTTEXT = "short_text",
      CREATEDAT = "created_at",
      CAMPAIGNIMGURL = "campaign_image_url",
      IMAGEURL = "image_url",
      BLUR_HASH = "blur_hash",
      SESSION_ID = "session_id",
      SHOW_IN_MAINFEED = "show_in_mainfeed",
      VIDEO_URL = "video_url";

  final String campaignId,
      campaignName,
      campaignImgUrl,
      campaignBlurHash,
      sessionId,
      sessionName,
      sessionImgUrl,
      sessionBlurHash,
      userId,
      organisationId,
      title,
      text,
      shortText,
      imageUrl,
      videoUrl,
      id,
      blurHash;
  DateTime createdAt;
  bool showInMainfeed;

  News(
      {this.campaignBlurHash,
      this.sessionName,
      this.sessionImgUrl,
      this.sessionBlurHash,
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
      this.blurHash,
      this.showInMainfeed = true});

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
      USERID: userId,
      SHOW_IN_MAINFEED: showInMainfeed
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
        blurHash: snapshot.data()[BLUR_HASH],
        showInMainfeed: snapshot.data()[SHOW_IN_MAINFEED]);
  }

  News.fromJson(Map<String, dynamic> map)
      : id = map['id'],
        campaignId = map[CAMPAIGNID],
        campaignName = map[CAMPAIGNNAME],
        campaignImgUrl = map[CAMPAIGNIMGURL],
        campaignBlurHash = map['campaign_blur_hash'],
        title = map[TITLE],
        text = map[TEXT],
        shortText = map[SHORTTEXT],
        sessionId = map[SESSION_ID],
        sessionName = map['session_name'],
        sessionImgUrl = map['session_img_url'],
        sessionBlurHash = map['session_blur_hash'],
        organisationId = map[ORGANISATION_ID],
        imageUrl = map[IMAGEURL],
        videoUrl = map[VIDEO_URL],
        userId = map[USERID],
        createdAt = DateTime.tryParse(map[CREATEDAT]),
        blurHash = map[BLUR_HASH],
        showInMainfeed = map[SHOW_IN_MAINFEED];

  static List<News> listFromJson(List<Map<String, dynamic>> list) {
    return list.map((map) => News.fromJson(map)).toList();
  }

  static List<News> listFromSnapshot(List<DocumentSnapshot> snapshot) {
    return snapshot.map(News.fromSnapshot).toList();
  }
}
