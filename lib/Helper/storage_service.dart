import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';

class StorageService {
  final FirebaseStorage storageRef = FirebaseStorage.instance;

  File file;

  StorageService({required this.file});

  Future<String> uploadImage(String name) async {
    return _upload(storageRef.ref("users/$name/$name.jpg").putFile(file));
  }

  Future<StorageStreamResult> uploadUserImage(String name,
      {BuildContext? context}) {
    return uploadImageStream(storageRef.ref("users/$name/$name.jpg"),
        context: context);
  }

  Future<StorageStreamResult> uploadImageStream(Reference ref,
      {BuildContext? context}) async {
    Stream<TaskSnapshot> snapStream = ref.putFile(file).snapshotEvents;

    String? downloadUrl;

    ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? controller;
    // ignore: close_sinks
    StreamController<String> streamController = StreamController<String>();
    streamController.add("Lade Bild hoch...");

    if (context != null) {
      controller = ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 60),
        backgroundColor: context.theme.colorScheme.secondary,
        content: StreamBuilder<String>(
            stream: streamController.stream.asBroadcastStream(),
            builder: (context, snap) {
              return Text(snap.data ?? "Fertig!");
            }),
      ));
    }

    await for (TaskSnapshot snap in snapStream) {
      print(snap);
      if (context != null) {
        streamController.add(
            "Lade Bild hoch: ${((snap.bytesTransferred / snap.totalBytes) * 100).round()}%");
      }

      if (snap.state == TaskState.success) {
        downloadUrl = await snap.ref.getDownloadURL();
        if (context != null) {
          streamController.add("Fertig!");
        }
        break;
      }
    }

    return StorageStreamResult(
        streamController: streamController,
        snackBarController: controller,
        url: downloadUrl);
  }

  Future<String> uploadNewsImage(String name) async {
    return _upload(storageRef.ref("news/$name/$name.jpg").putFile(file));
  }

  Future<String> uploadSessionImage(String name) async {
    return _upload(storageRef.ref("sessions/$name/$name.jpg").putFile(file));
  }

  Future<StorageStreamResult> uploadSessionImageStream(String name,
      {BuildContext? context}) {
    return uploadImageStream(storageRef.ref("sessions/$name/$name.jpg"),
        context: context);
  }

  Future<String> _upload(UploadTask task) async {
    String downlUrl = "";
    await task.then((ts) async => downlUrl = await ts.ref.getDownloadURL());
    return downlUrl;
  }

  static String userImageName(String? uid) => "user_$uid";
  static String campaignImageName(String id) => "campaign_$id";
  static String newsImageName(String id) => "news_$id";
  static String sessionImageName(String? id) => "session_$id";
}

class StorageStreamResult {
  final StreamController<String> streamController;
  final ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
      snackBarController;
  final String? url;

  StorageStreamResult(
      {required this.streamController, this.snackBarController, this.url});

  Future<void> finish() async {
    await streamController.close();
    if (snackBarController != null) {
      snackBarController!.close();
      await snackBarController!.closed;
    }
  }

  Future<void> error() async {
    streamController.add("Etwas ist schief gelaufen beim hochladen...");

    await Future.delayed(Duration(milliseconds: 2000));

    await finish();
  }
}
