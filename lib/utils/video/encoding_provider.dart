import 'dart:io';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

removeExtension(String path) {
  final str = path.substring(0, path.length - 4);
  return str;
}

class EncodingProvider {
  static final FlutterFFmpeg _encoder = FlutterFFmpeg();
  static final FlutterFFprobe _probe = FlutterFFprobe();
  static final FlutterFFmpegConfig _config = FlutterFFmpegConfig();

  static Future<String> encodeHLS(videoPath, outDirPath) async {
    return outDirPath;
  }

  static double getAspectRatio(Map<dynamic, dynamic> info) {
    final int width = info['streams'][0]['width'];
    final int height = info['streams'][0]['height'];
    final double aspect = height / width;
    return aspect;
  }

  static Future<String> getThumb(videoPath, width, height) async {
    assert(File(videoPath).existsSync());

    final String outPath = '$videoPath.jpg';
    final arguments =
        '-y -i $videoPath -vframes 1 -an -s ${width}x${height} -ss 1 $outPath';

    final int rc = await _encoder.execute(arguments);
    assert(rc == 0);
    assert(File(outPath).existsSync());

    return outPath;
  }

  static void enableStatisticsCallback(Function cb) {
    return _config.enableStatisticsCallback(cb);
  }

  static Future<void> cancel() async {
    await _encoder.cancel();
  }

  static Future<Map<dynamic, dynamic>> getMediaInformation(String path) async {
    assert(File(path).existsSync());

    return await _probe.getMediaInformation(path);
  }

  static int getDuration(Map<dynamic, dynamic> info) {
    return info['duration'];
  }

  static void enableLogCallback(
      void Function(int level, String message) logCallback) {
    _config.enableLogCallback(logCallback);
  }
}