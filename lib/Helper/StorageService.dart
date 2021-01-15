import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage storageRef = FirebaseStorage.instance;

  File file;

  StorageService({this.file});

  Future<String> uploadImage(String name) async {
    UploadTask task = storageRef.ref("users/$name/$name.jpg").putFile(file);
    String downlUrl = "";
    await task.then((ts) async => downlUrl = await ts.ref.getDownloadURL());
    return downlUrl;
  }

  Future<String> uploadNewsImage(String name) async {
    UploadTask task = storageRef.ref("news/$name/$name.jpg").putFile(file);
    String downlUrl = "";
    await task.then((ts) async => downlUrl = await ts.ref.getDownloadURL());
    return downlUrl;
  }

  static String userImageName(String uid) => "user_$uid";
  static String campaignImageName(String id) => "campaign_$id";
  static String newsImageName(String id) => "news_$id";
}
