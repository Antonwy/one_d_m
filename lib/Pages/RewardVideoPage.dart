import 'dart:async';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:provider/provider.dart';

class RewardVideoPage extends StatefulWidget {
  @override
  _RewardVideoPageState createState() => _RewardVideoPageState();
}

class _RewardVideoPageState extends State<RewardVideoPage> {
  bool _loadingAd;

  Future<bool> _loadAd({bool show: true}) {
    setState(() {
      _loadingAd = show;
    });
    return RewardedVideoAd.instance.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917',
    );
  }

  Future<void> _showIfAlreadyAvailable() async {
    try {
      await RewardedVideoAd.instance.show();
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();

    RewardedVideoAd.instance.listener = (RewardedVideoAdEvent event,
        {String rewardType, int rewardAmount}) async {
      if (event == RewardedVideoAdEvent.loaded) {
        if (mounted && _loadingAd) {
          RewardedVideoAd.instance.show();
        }

        setState(() {
          _loadingAd = false;
        });
      } else if (event == RewardedVideoAdEvent.rewarded) {
        print('REWARD');
        await DatabaseService.addInterstitialImpression(
          Provider.of<UserManager>(context, listen: false).uid,
        );
      } else if (event == RewardedVideoAdEvent.closed ||
          event == RewardedVideoAdEvent.completed) {
        _loadAd(show: false);
      }
    };
    _loadAd(show: false).then((value) => print('loadAd() -> $value'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Video-Area",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(height: 50.0),
            Text(
              'Spiele hier Videos ab und booste deinen Aktivitätsscore!',
              style: TextStyle(fontSize: 15.0),
              textAlign: TextAlign.center,
            ),
            Container(height: 100.0),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Material(
                child: InkWell(
                  onTap: _loadingAd == false
                      ? () async {
                          _loadAd(show: true);
                          _showIfAlreadyAvailable();
                        }
                      : null,
                  child: Container(
                    color: ColorTheme.orange,
                    width: 100,
                    height: 100,
                    child: Center(
                      child: _loadingAd == false
                          ? Icon(
                              Icons.play_arrow,
                              size: 65,
                              color: Colors.white,
                            )
                          : CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
