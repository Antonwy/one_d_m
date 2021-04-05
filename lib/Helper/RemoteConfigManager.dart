import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:package_info/package_info.dart';

class RemoteConfigManager {
  static const String MIN_BUILD_NUMBER = "min_build_number";
  static const String MAX_DVS_PER_DAY = "max_dvs_per_day";
  static const int MAX_DVS_PER_DAY_DEFAULT = Constants.DVS_PER_DAY;

  RemoteConfig _remoteConfig;
  PackageInfo packageInfo;
  bool shouldUpdate = false;

  Future initialize() async {
    _remoteConfig = await RemoteConfig.instance;
    packageInfo = await PackageInfo.fromPlatform();
    try {
      final Map<String, dynamic> defaults = _createDefaults();

      await _remoteConfig.setDefaults(defaults);
      await fetchAndActivate();
      shouldUpdate = _checkIfShouldUpdate();
      _printInfos();
    } on FetchThrottledException catch (e) {
      print("Remote config fetch throttled: $e");
    } catch (e) {
      print("Unable to fetch remote config, defaults will be used. $e");
    }
  }

  void _printInfos() {
    print(
        "RemoteConfig initialized! Defaults are: MinVersion: ${_remoteConfig.getString(MIN_BUILD_NUMBER)}");
    print("CurrentVersion is: ${_getDefaultBuildNumber()}");
    print("RemoteConfig Version is: ${_remoteConfig.getInt(MIN_BUILD_NUMBER)}");
    print("RemoteConfig suggests to update version: $shouldUpdate");
    print("Max DVs to collect: ${_remoteConfig.getString(MAX_DVS_PER_DAY)}");
  }

  Map<String, dynamic> _createDefaults() {
    return {
      MIN_BUILD_NUMBER: _getDefaultBuildNumber(),
      MAX_DVS_PER_DAY: MAX_DVS_PER_DAY_DEFAULT
    };
  }

  int _getDefaultBuildNumber() => int.tryParse(packageInfo.buildNumber) ?? 1;

  Future fetchAndActivate() async {
    await _remoteConfig.fetch(expiration: Duration(seconds: 0));
    await _remoteConfig.activateFetched();
  }

  bool _checkIfShouldUpdate() {
    return _remoteConfig.getInt(MIN_BUILD_NUMBER) > _getDefaultBuildNumber();
  }

  int get maxDVs => _remoteConfig.getInt(MAX_DVS_PER_DAY);
}

class AppVersion {
  static final String VERSION = "version", BUILD_NUMBER = "build_number";
  static const AppVersion currentVersion =
      AppVersion(version: "1.0.7", buildNumber: 51);

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
