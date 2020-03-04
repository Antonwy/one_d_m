import 'package:intl/intl.dart';

class News {

  int projectId, userId;
  String title, imageUrl, text;
  DateTime createdAt;

  News({this.projectId, this.userId, this.title, this.imageUrl, this.text, this.createdAt});

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      projectId: json["project_id"],
      userId: json["user_id"],
      title: json["title"],
      imageUrl: "https://source.unsplash.com/random/${json["user_id"]}",
      text: json["text"],
      createdAt: DateFormat("yyyy-MM-dd HH:mm:ss").parseLoose(json["created_at"]),
    );
  }


}