import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;

class StorageService {
  final StorageReference storageRef = FirebaseStorage.instance.ref();

  File file;
  String id;

  StorageService({this.file, this.id});

  Future<File> compressImage({int quality = 40}) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image image = Im.decodeImage(file.readAsBytesSync());
    File compressedImageFile = File("$path/img_$id.jpg")
      ..writeAsBytesSync(Im.encodeJpg(image, quality: quality));
    file = compressedImageFile;
    return compressedImageFile;
  }

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
      print(name);
      await storageRef.child(name).delete();
    }
  }
}
