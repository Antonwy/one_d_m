import 'dart:io';
import 'Constants.dart';

class AdManager {
  static String get appId {
    if (Platform.isAndroid) {
      return Constants.ADMOB_APP_ID_ANDROID;
    } else if (Platform.isIOS) {
      return Constants.ADMOB_APP_ID_IOS;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return Constants.ADMOB_REWARD_ID_ANDROID;
    } else if (Platform.isIOS) {
      return Constants.ADMOB_REWARD_ID_IOS;
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}
