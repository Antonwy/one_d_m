import 'package:cloud_firestore/cloud_firestore.dart';

class News {
  static const String CAMPAIGNID = "campaign_id",
      CAMPAIGNNAME = "campaign_name",
      ORGANIZATIONNAME = "organization_name",
      USERID = "user_id",
      TITLE = "title",
      TEXT = "text",
      SHORTTEXT = "short_text",
      CREATEDAT = "created_at",
      CAMPAIGNIMGURL = "campaign_image_url",
      IMAGEURL = "image_url",
      BLUR_HASH = "blur_hash",
      SESSION_ID = "session_id",
      VIDEO_URL = "video_url";

  final String campaignId, text, id;
  final String? campaignName,
      campaignImgUrl,
      campaignBlurHash,
      sessionId,
      sessionName,
      sessionImgUrl,
      sessionBlurHash,
      organizationName,
      title,
      shortText,
      imageUrl,
      videoUrl,
      blurHash;
  final DateTime createdAt;
  final bool adminNews;

  News(
      {this.campaignBlurHash,
      this.sessionName,
      this.sessionImgUrl,
      this.sessionBlurHash,
      required this.campaignId,
      required this.id,
      this.title,
      required this.campaignImgUrl,
      required this.text,
      this.shortText,
      required this.createdAt,
      required this.campaignName,
      this.imageUrl,
      this.videoUrl,
      this.sessionId,
      this.blurHash,
      this.organizationName,
      this.adminNews = false});

  Map<String, dynamic> toMap() {
    return {
      CAMPAIGNID: campaignId,
      CAMPAIGNNAME: campaignName,
      TITLE: title,
      TEXT: text,
      SHORTTEXT: shortText,
      IMAGEURL: imageUrl,
      VIDEO_URL: videoUrl,
      CAMPAIGNIMGURL: campaignImgUrl,
      CREATEDAT: Timestamp.now(),
      SESSION_ID: sessionId,
    };
  }

  static News fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return News(
      id: snapshot.id,
      campaignId: data[CAMPAIGNID],
      title: data[TITLE],
      text: data[TEXT],
      shortText: data[SHORTTEXT],
      campaignName: data[CAMPAIGNNAME],
      campaignImgUrl: data[CAMPAIGNIMGURL],
      sessionId: data[SESSION_ID],
      imageUrl: data[IMAGEURL],
      videoUrl: data[VIDEO_URL],
      createdAt: (data[CREATEDAT] as Timestamp).toDate(),
      blurHash: data[BLUR_HASH],
    );
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
        imageUrl = map[IMAGEURL],
        videoUrl = map[VIDEO_URL],
        createdAt = DateTime.tryParse(map[CREATEDAT]) ?? DateTime.now(),
        blurHash = map[BLUR_HASH],
        organizationName = map[ORGANIZATIONNAME],
        adminNews = map["admin_news"] ?? false;

  static List<News> listFromJson(List<Map<String, dynamic>> list) {
    return list.map((map) => News.fromJson(map)).toList();
  }

  static List<News> listFromSnapshot(List<DocumentSnapshot> snapshot) {
    return snapshot.map(News.fromSnapshot).toList();
  }
}
