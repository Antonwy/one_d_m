import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final StorageReference storageRef = FirebaseStorage.instance.ref();

  File file;

  StorageService({this.file});

  Future<String> uploadImage(String name) async {
    StorageUploadTask task =
        storageRef.child("users/$name/$name.jpg").putFile(file);
    StorageTaskSnapshot snapshot = await task.onComplete;
    return await snapshot.ref.getDownloadURL();
  }

  static String userImageName(String uid) => "user_$uid";
  static String campaignImageName(String id) => "campaign_$id";
  static String newsImageName(String id) => "news_$id";
}
