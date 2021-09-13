import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage storageRef = FirebaseStorage.instance;

  File file;

  StorageService({this.file});

  Future<String> uploadImage(String name) async {
    return _upload(storageRef.ref("users/$name/$name.jpg").putFile(file));
  }

  Future<String> uploadNewsImage(String name) async {
    return _upload(storageRef.ref("news/$name/$name.jpg").putFile(file));
  }

  Future<String> uploadSessionImage(String name) async {
    return _upload(storageRef.ref("sessions/$name/$name.jpg").putFile(file));
  }

  Future<String> _upload(UploadTask task) async {
    String downlUrl = "";
    await task.then((ts) async => downlUrl = await ts.ref.getDownloadURL());
    return downlUrl;
  }

  static String userImageName(String uid) => "user_$uid";
  static String campaignImageName(String id) => "campaign_$id";
  static String newsImageName(String id) => "news_$id";
  static String sessionImageName(String id) => "session_$id";
}
