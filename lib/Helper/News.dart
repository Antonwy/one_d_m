import 'package:cloud_firestore/cloud_firestore.dart';

class News {
  static final String CAMPAIGNID = "campaign_id",
      CAMPAIGNNAME = "campaign_name",
      USERID = "user_id",
      TITLE = "title",
      TEXT = "text",
      SHORTTEXT = "short_text",
      CREATEDAT = "created_at",
      CAMPAIGNIMGURL = "campaign_img_url",
      IMAGEURL = "image_url";

  String campaignId,
      userId,
      campaignName,
      campaignImgUrl,
      title,
      imageUrl,
      text,
      shortText,
      id;
  DateTime createdAt;

  News(
      {this.campaignId,
      this.id,
      this.userId,
      this.title,
      this.campaignImgUrl,
      this.imageUrl,
      this.text,
      this.shortText,
      this.createdAt,
      this.campaignName});

  Map<String, dynamic> toMap() {
    return {
      CAMPAIGNID: campaignId,
      CAMPAIGNNAME: campaignName,
      USERID: userId,
      TITLE: title,
      TEXT: text,
      SHORTTEXT: shortText,
      IMAGEURL: imageUrl,
      CAMPAIGNIMGURL: campaignImgUrl,
      CREATEDAT: Timestamp.now()
    };
  }

  static News fromSnapshot(DocumentSnapshot snapshot) {
    return News(
      id: snapshot.documentID,
      campaignId: snapshot[CAMPAIGNID],
      userId: snapshot[USERID],
      title: snapshot[TITLE],
      text: snapshot[TEXT],
      shortText: snapshot[SHORTTEXT],
      campaignName: snapshot[CAMPAIGNNAME],
      campaignImgUrl: snapshot[CAMPAIGNIMGURL],
      imageUrl: snapshot[IMAGEURL],
      createdAt: (snapshot[CREATEDAT] as Timestamp).toDate(),
    );
  }

  static List<News> listFromSnapshot(List<DocumentSnapshot> snapshot) {
    return snapshot.map(News.fromSnapshot).toList();
  }
}
