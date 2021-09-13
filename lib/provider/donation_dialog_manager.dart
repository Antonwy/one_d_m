import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/api/stream_result.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/helper/helper.dart';
import 'package:one_d_m/models/donation.dart';
import 'package:one_d_m/models/donation_request.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

class DonationDialogManager extends ChangeNotifier {
  bool _showThankYou = false,
      _customAmount = false,
      _anonym = false,
      _useDCs = true,
      _hasPaymentMethod = false,
      _showAnimation = false;

  // IMPORTANT
  final String campaignId, sessionId;
  final BuildContext context;
  DonationRequest dr;
  Future<Artboard> artboardFuture;
  RiveAnimationController riveController;
  String currentAnimation = '-0';
  int _currentAnimationIndex = 0, _amount = 0;
  Artboard artboardController;
  bool _loading = false, initialLoading = true, fromCache = true, noConnection;
  double _opacity = 0;

  Donation donation;

  DonationDialogManager(
      {this.context,
      this.campaignId,
      this.sessionId,
      this.noConnection = false}) {
    _amount = 0;
    initData();
  }

  Future<void> initData() async {
    if (noConnection) {
      opacity = 1;
      return;
    }
    final endpoint = sessionId != null
        ? Api().donationRequest().session(sessionId)
        : Api().donationRequest().campaign(campaignId);

    Future.delayed(Duration(milliseconds: 125)).then((val) {
      if (initialLoading) opacity = 1;
    });

    int i = 0;

    try {
      await for (StreamResult<DonationRequest> sRes
          in endpoint.streamGetOne()) {
        dr = sRes.data;
        fromCache = sRes.fromCache;

        if (fromCache) dr.userBalance = 0;

        if (dr.animationUrl != null && artboardFuture == null) {
          artboardFuture = _loadAndCacheRive();
          artboardController = await artboardFuture;
        }

        if (_opacity == 1 && i == 0) {
          opacity = 0;
          await Future.delayed(Duration(milliseconds: 500));
        }

        initialLoading = false;
        _opacity = 1;

        if (dr.userBalance >= dr.unit.value) _amount = dr.unit.value;

        notifyListeners();

        i++;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<Artboard> _loadAndCacheRive() async {
    try {
      final cacheManager = DefaultCacheManager();
      FileInfo fileInfo = await cacheManager.getFileFromCache(dr.animationUrl);
      // Get video from cache first

      if (fileInfo?.file == null) {
        fileInfo = await cacheManager.downloadFile(dr.animationUrl);
      }

      Uint8List list = await fileInfo.file.readAsBytes();
      ByteData byteData = ByteData.view(list.buffer);

      final file = RiveFile();

      if (file.import(byteData)) {
        final artboard = file.mainArtboard;

        artboard
            .addController(riveController = SimpleAnimation(currentAnimation));
        return artboard;
      }
    } catch (e) {
      print(e);
    }
  }

  void _switchRiveAnimation(String direction) {
    if (dr.animationUrl != null) {
      int index = amount ~/ dr.unit.value;
      //prevent playing same animation again
      if (_currentAnimationIndex == index || index > 5) return;

      _currentAnimationIndex = index;
      currentAnimation = '$direction$index';
      //change animation name
      print('Current animation: $currentAnimation');
      if (artboardController == null) return;

      artboardController.removeController(riveController);
      artboardController
          .addController(riveController = SimpleAnimation(currentAnimation));
    }
  }

  void sub() {
    int newValue = amount - dr.unit.value;
    if (newValue >= 0) {
      HapticFeedback.heavyImpact();
      amount = newValue;

      _switchRiveAnimation('-');
    }
  }

  void add() {
    int newValue = amount + dr.unit.value;
    if (dr.userBalance >= newValue) {
      HapticFeedback.heavyImpact();
      amount = newValue;

      _switchRiveAnimation('+');
    } else {
      Helper.showAlert(
          context, "Du musst mehr DVs sammeln um weiter spenden zu können.",
          title: "Zu wenig DVs!");
    }
  }

  Future<void> donate() async {
    if (amount > dr.userBalance) return;

    Donation donation = Donation(amount,
        campaignId: dr.campaignId,
        alternativeCampaignId: dr.campaignId,
        userId: dr.userId,
        sessionId: dr.sessionId);

    if (amount >= 100) {
      bool res = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("Bist du dir sicher?"),
                content: Text(
                    "Willst du wirklich $amount DV zum unterstützen ausgeben?"),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Constants.radius)),
                actions: <Widget>[
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      child: Text(
                        "ABBRECHEN",
                        style: TextStyle(color: Colors.red),
                      )),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      child: Text(
                        "UNTERSTÜTZEN",
                        style: TextStyle(color: Colors.blueGrey),
                      )),
                ],
              ));
      if (!res) return;
    }

    loading = true;

    //await Future.delayed(Duration(milliseconds: 200));
    // await DatabaseService.donate(donation);
    try {
      this.donation = await Api().donations().create(donation);
      await context
          .read<FirebaseAnalytics>()
          ?.logEvent(name: "Donation", parameters: {
        "amount": donation.amount,
        "campaign": donation.campaignName,
        "session": donation?.sessionId ?? ""
      });
      await context.read<UserManager>().reloadUser();
    } catch (e) {
      print("ERROR");
      print(e);
    }

    toThankYou();
  }

  Future<void> toThankYou() async {
    opacity = 0;
    await Future.delayed(Duration(milliseconds: 250));
    _showAnimation = true;
    opacity = 1;
  }

  int get amount => _amount;

  set amount(int a) {
    _amount = a;
    notifyListeners();
  }

  bool get showThankYou => _showThankYou;

  set showThankYou(bool sty) {
    _showThankYou = sty;
    notifyListeners();
  }

  bool get loading => _loading;

  set loading(bool l) {
    _loading = l;
    notifyListeners();
  }

  double get opacity => _opacity;

  set opacity(double o) {
    _opacity = o;
    notifyListeners();
  }

  bool get showAnimation => _showAnimation;

  set showAnimation(bool sty) {
    _showAnimation = sty;
    notifyListeners();
  }

  void setLoadingWithoutRebuild(bool l) {
    _loading = l;
  }
}
