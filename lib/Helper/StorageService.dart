import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final StorageReference storageRef = FirebaseStorage.instance.ref();

  File file;
  String id;

  StorageService({this.file, this.id});

  Future<String> uploadImage() async {
    StorageUploadTask task = storageRef.child("campaign_$id.jpg").putFile(file);
    StorageTaskSnapshot snapshot = await task.onComplete;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> deleteOld(String url) async {
    RegExp expr = RegExp("campaign_(.*).jpg");
    RegExpMatch match = expr.firstMatch(url);
    if (match != null) {
      String name = url.substring(match.start, match.end);
      await storageRef.child(name).delete();
    }
  }
}
