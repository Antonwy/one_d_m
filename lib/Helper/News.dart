import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:one_d_m/Helper/ImageUrl.dart';

class News {
  static final String CAMPAIGNID = "campaign_id",
      CAMPAIGNNAME = "campaign_name",
      ORGANISATION_ID = "organisation_id",
      TITLE = "title",
      TEXT = "text",
      SHORTTEXT = "short_text",
      CREATEDAT = "created_at",
      CAMPAIGNIMGURL = "campaign_img_url",
      IMAGEURL = "image_url";

  String campaignId,
      organisationId,
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
    this.organisationId,
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
      ORGANISATION_ID: organisationId,
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
      organisationId: snapshot[ORGANISATION_ID],
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
