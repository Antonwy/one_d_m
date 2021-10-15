import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_applovin_max/flutter_applovin_max.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/components/push_notification.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/helper/helper.dart';
import 'package:one_d_m/provider/remote_config_manager.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static String get appLovinId {
    if (Platform.isAndroid) {
      return Constants.APPLOVIN_REWARD_ID_ANDROID;
    } else if (Platform.isIOS) {
      return Constants.APPLOVIN_REWARD_ID_IOS;
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

class AdManagerNotifier extends ChangeNotifier {
  int alreadyCollectedCoins = 0;
  late int maxDVs;
  late AdNetwork adNetwork;

  bool loading = false;

  InterstitialAd? _ad;

  final BuildContext context;

  AdManagerNotifier(BuildContext context) : this.context = context {
    RemoteConfigManager rcm = context.read<RemoteConfigManager>();
    maxDVs = rcm.maxDVs;
    adNetwork = rcm.adNetwork;

    _initAds();
    _initStorage();
  }

  Future<void> _initAds() async {
    await FlutterApplovinMax.initRewardAd(AdManager.appLovinId);
    await _preloadAdmob();
  }

  bool get done => alreadyCollectedCoins >= maxDVs;

  void _initStorage() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    DateFormat format = DateFormat.yMd();
    String today = format.format(DateTime.now());
    String? _lastTimeResetted =
        _prefs.getString(Constants.LAST_TIME_RESETTED_COINS);

    if (_lastTimeResetted == null) {
      print('_lastTimeResetted was null');
      _lastTimeResetted = today;
      await _prefs.setString(Constants.LAST_TIME_RESETTED_COINS, today);
    }

    print("LastTimeResetted: $_lastTimeResetted");

    if (_lastTimeResetted != today) {
      print('LastTimeResetted != Today => resetting coins');
      await _prefs.setInt(Constants.COllECTED_COINS_KEY, 0);
      await _prefs.setString(Constants.LAST_TIME_RESETTED_COINS, today);
    }

    int _collCoins = _prefs.getInt(Constants.COllECTED_COINS_KEY) ?? 0;
    alreadyCollectedCoins = _collCoins;
    notifyListeners();
  }

  Future<void> _preloadAdmob([bool show = false]) async {
    if (show) {
      loading = true;
      notifyListeners();
    }

    await InterstitialAd.load(
        adUnitId: AdManager.rewardedAdUnitId,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) {
          print("AD LOADED");
          print(ad);

          _ad = ad;

          if (show) showAd();
        }, onAdFailedToLoad: (e) {
          print("FAILED LOADING AD");

          print(e.message);
        }));

    if (show) {
      loading = false;
      notifyListeners();
    }
  }

  dynamic _listener(AppLovinAdListener? event) {
    print(event);

    if (event == AppLovinAdListener.onUserRewarded) {
      print('👍get reward');

      _adViewed();
    } else if (event == AppLovinAdListener.adLoadFailed) _showError();
  }

  void _adViewed() async {
    print("AD VIEWED");
    _collectCoin();
    context.read<FirebaseAnalytics>().logEvent(name: "Reward earned");
    await Api().account().addDvs();

    await context.read<UserManager>().reloadUser();

    loading = false;
    notifyListeners();

    PushNotification.of(context)
        .show(NotificationContent(title: "Neuer DV!", body: _pushMsgTitle()));
  }

  Future<void> showAd() async {
    if (done) {
      Helper.showAlert(context, "Du hast heute bereits $maxDVs DVs gesammelt!",
          title: "Das wars für heute!");
      return;
    }

    loading = true;
    notifyListeners();

    print("SHOWING AD");
    if (adNetwork == AdNetwork.admob) {
      bool res = await _tryAdmob();
      if (!res) {
        print("FAILED ADMOB");
        bool res2 = await _tryAppLovin();
        if (!res2) _showError();
      }
    } else if (adNetwork == AdNetwork.applovin) {
      bool res = await _tryAppLovin();
      if (!res) {
        print("FAILED APPLOVIN");
        bool res2 = await _tryAdmob();
        if (!res2) _showError();
      }
    }
  }

  Future<bool> _tryAdmob() async {
    print("TRIES ADMOB");

    if (_ad == null) await _preloadAdmob(true);
    if (_ad == null) return false;

    _ad!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');

        _showError();

        ad.dispose();
      },
      onAdImpression: (InterstitialAd ad) {
        _adViewed();
        print('$ad impression occurred.');
        ad.dispose();
      },
    );

    await _ad!.show();
    _ad = null;
    await _preloadAdmob();
    return true;
  }

  Future<bool> _tryAppLovin() async {
    print("TRIES APPLOVIN");

    bool available =
        (await FlutterApplovinMax.isRewardLoaded(_listener)) ?? false;
    print("APPLOVIN AD AVAILABLE: $available");
    if (available) {
      await FlutterApplovinMax.showRewardVideo(_listener);
      return true;
    } else
      return false;
  }

  void _showError() {
    loading = false;
    notifyListeners();

    PushNotification.of(context).show(NotificationContent(
        isWarning: true,
        title: "Das hat leider nicht funktioniert.",
        body:
            "Momentan haben wir leider keine Werbung die wir dir zeigen können.",
        icon: Icons.error_outline));
  }

  String _pushMsgTitle() {
    if (done) return "Das wars für heute. Vielen Dank für deine Aktivität!";

    return "Viel Spaß beim Spenden!";
  }

  void _collectCoin() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    int collectedCoins = _prefs.getInt(Constants.COllECTED_COINS_KEY) ?? 0;
    print("collect coin: $collectedCoins");
    await _prefs.setInt(Constants.COllECTED_COINS_KEY, ++collectedCoins);
    alreadyCollectedCoins = collectedCoins;
    print('Already collected coins: $alreadyCollectedCoins');

    notifyListeners();
  }
}
