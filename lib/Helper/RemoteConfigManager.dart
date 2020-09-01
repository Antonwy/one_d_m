import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class RemoteConfigManager extends ChangeNotifier {
  static final String MIN_VERSION = "min_version",
      MIN_BUILD_NUMBER = "min_build_number";
  final RemoteConfig _remoteConfig;
  final String _minVersionDefault = "1.0.7";
  final int _minBuildNumberDefault = 51;

  static RemoteConfigManager _instance;

  static Future<RemoteConfigManager> getInstance() async {
    if (_instance != null) {
      _instance =
          RemoteConfigManager(remoteConfig: await RemoteConfig.instance);
    }
    return _instance;
  }

  RemoteConfigManager({RemoteConfig remoteConfig})
      : _remoteConfig = remoteConfig;

  Future<bool> get mustUpdateApp async {
    AppVersion currVersion = await AppVersion.getAppVersion();
    return currVersion.mustUpdate(AppVersion(
        version: _remoteConfig.getString(MIN_VERSION),
        buildNumber: _remoteConfig.getInt(MIN_BUILD_NUMBER)));
  }
}

class AppVersion {
  static final String VERSION = "version", BUILD_NUMBER = "build_number";
  static final AppVersion defaultVersion =
      const AppVersion(version: "1.0.7", buildNumber: 51);

  final String version;
  final int buildNumber;

  const AppVersion({this.version, this.buildNumber});

  Map<String, dynamic> toMap() => {VERSION: version, BUILD_NUMBER: buildNumber};
  static AppVersion fromMap(Map<String, dynamic> map) =>
      AppVersion(version: map[VERSION], buildNumber: map[BUILD_NUMBER]);

  static Future<AppVersion> getAppVersion() async {
    PackageInfo info = await PackageInfo.fromPlatform();
    return AppVersion(
        version: info.version, buildNumber: int.parse(info.buildNumber));
  }

  bool mustUpdate(AppVersion minVersion) {
    if (minVersion.version != this.version) return true;
    if (minVersion.buildNumber > this.buildNumber) return true;
    return false;
  }
}
