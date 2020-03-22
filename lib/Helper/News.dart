import 'package:cloud_firestore/cloud_firestore.dart';

class News {
  static final String CAMPAIGNID = "campaign_id",
      CAMPAIGNNAME = "campaign_name",
      USERID = "user_id",
      TITLE = "title",
      TEXT = "text",
      SHORTTEXT = "short_text",
      CREATEDAT = "created_at",
      IMAGEURL = "image_url";
  String campaignId, userId, campaignName, title, imageUrl, text, shortText, id;
  DateTime createdAt;

  News(
      {this.campaignId,
      this.id,
      this.userId,
      this.title,
      this.imageUrl =
          "https://images.unsplash.com/photo-1568025848823-86404cd04ad1?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=3367&q=80",
      this.text,
      this.shortText,
      this.createdAt,
      this.campaignName});

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      campaignId: json[CAMPAIGNID],
      userId: json[USERID],
      title: json[TITLE],
      text: json[TEXT],
      shortText: json[SHORTTEXT],
      campaignName: json[CAMPAIGNNAME],
      imageUrl: json[IMAGEURL],
      createdAt: DateTime.fromMicrosecondsSinceEpoch(json[CREATEDAT] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      CAMPAIGNID: campaignId,
      CAMPAIGNNAME: campaignName,
      USERID: userId,
      TITLE: title,
      TEXT: text,
      SHORTTEXT: shortText,
      IMAGEURL: imageUrl,
      CREATEDAT: DateTime.now().millisecondsSinceEpoch
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
      imageUrl: snapshot[IMAGEURL],
      createdAt: DateTime.fromMicrosecondsSinceEpoch(snapshot[CREATEDAT] ?? 0),
    );
  }

  static List<News> listFromSnapshot(List<DocumentSnapshot> snapshot) {
    return snapshot.map(News.fromSnapshot).toList();
  }
}
