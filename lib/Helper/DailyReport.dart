import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DailyReport {
  final String title, subtitle, text, date, goodbye;
  final List<WhatWeReached> whatWeReached;

  const DailyReport(
      {this.title,
      this.subtitle,
      this.text,
      this.whatWeReached,
      this.date,
      this.goodbye});

  factory DailyReport.fromDoc(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data();

    List<Map<String, dynamic>> wwr = [];

    if (data[WHAT_WE_REACHED] != null) wwr = List.from(data[WHAT_WE_REACHED]);

    return DailyReport(
        title: data[TITLE],
        subtitle: data[SUBTITLE],
        text: data[TEXT],
        date: doc.id,
        whatWeReached: WhatWeReached.convertToList(wwr),
        goodbye: data[GOODBYE]);
  }

  static List<DailyReport> fromQuerySnapshot(QuerySnapshot qs) {
    return qs.docs.map((doc) => DailyReport.fromDoc(doc)).toList();
  }

  static const String TITLE = "title",
      SUBTITLE = "subtitle",
      TEXT = "text",
      GOODBYE = "goodbye",
      WHAT_WE_REACHED = "what_we_reached";
}

class WhatWeReached {
  final String text;
  final int value;

  const WhatWeReached({this.text, this.value});

  factory WhatWeReached.fromMap(Map<String, dynamic> map) {
    return WhatWeReached(text: map[DailyReport.TEXT], value: map[VALUE]);
  }

  static List<WhatWeReached> convertToList(List<Map<String, dynamic>> list) {
    List<WhatWeReached> wwr = [];

    for (Map<String, dynamic> map in list) {
      wwr.add(WhatWeReached.fromMap(map));
    }

    return wwr;
  }

  static const String VALUE = "value";
}
