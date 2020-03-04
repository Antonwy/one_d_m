import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';

class Campaign {
  String name, description, city, imgUrl;
  File img;
  DateTime endDate;
  int amount, finalAmount, id, authorId;
  bool subscribed;

  Campaign({
    this.id = 0,
    this.name,
    this.description,
    this.city,
    this.endDate,
    this.authorId,
    this.amount = 10000,
    this.imgUrl =
        "https://images.unsplash.com/photo-1568025848823-86404cd04ad1?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=3367&q=80",
    this.img,
    this.finalAmount = 200000,
    this.subscribed = false,
  });

  static Campaign fromJson(Map<String, dynamic> json) {
    if(json.containsKey("data")) json = json["data"];
    return new Campaign(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        city: json["city"],
        endDate: DateFormat("yyyy-MM-dd HH:mm:ss").parseLoose(json["end_date"]),
        authorId: json["admin_id"],
        subscribed: json["subscribed"],
        imgUrl: "https://source.unsplash.com/random/${json["city"]}",
        img: new File(json["thumbnail"]));
  }

  Map<String, dynamic> toMap() {
    print(endDate);
    return {
      "name": name,
      "description": description,
      "city": city,
      "end_date": DateFormat('yyyy-MM-dd HH:mm:ss').format(endDate),
      "image": img != null ? base64Encode(img.readAsBytesSync()) : ""
    };
  }

  void toggleSubscribed() {
    subscribed = !subscribed;
  }

  @override
  String toString() {
    return 'Campaign{name: $name, description: $description, city: $city, imgUrl: $imgUrl, endDate: $endDate, amount: $amount, finalAmount: $finalAmount, id: $id, authorId: $authorId, subscribed: $subscribed}';
  }
}
