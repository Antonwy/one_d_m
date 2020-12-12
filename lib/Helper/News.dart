import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:one_d_m/Helper/ImageUrl.dart';

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
      text,
      shortText,
      imageUrl,
      id;
  DateTime createdAt;

  News({
    this.campaignId,
    this.id,
    this.userId,
    this.title,
    this.campaignImgUrl,
    this.text,
    this.shortText,
    this.createdAt,
    this.campaignName,
    this.imageUrl,
  });

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
      id: snapshot.id,
      campaignId: snapshot.data()[CAMPAIGNID],
      userId: snapshot.data()[USERID],
      title: snapshot.data()[TITLE],
      text: snapshot.data()[TEXT],
      shortText: snapshot.data()[SHORTTEXT],
      campaignName: snapshot.data()[CAMPAIGNNAME],
      campaignImgUrl: snapshot.data()[CAMPAIGNIMGURL],
      imageUrl: snapshot.data()[IMAGEURL],
      createdAt: (snapshot.data()[CREATEDAT] as Timestamp).toDate(),
    );
  }

  static List<News> listFromSnapshot(List<DocumentSnapshot> snapshot) {
    return snapshot.map(News.fromSnapshot).toList();
  }
}
