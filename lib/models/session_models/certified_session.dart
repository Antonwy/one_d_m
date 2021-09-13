import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:one_d_m/models/session_models/session.dart';

class CertifiedSession extends Session {
  final String videoUrl;

  CertifiedSession.fromDoc(DocumentSnapshot doc)
      : videoUrl = doc.data()[VIDEO_URL],
        super.fromDoc(doc);

  CertifiedSession.fromJson(Map<String, dynamic> map)
      : videoUrl = map[VIDEO_URL],
        super.fromJson(map);

  static const String VIDEO_URL = "video_url";
}
