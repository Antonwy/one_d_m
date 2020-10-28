import 'dart:async';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
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
      adUnitId: Constants.ADMOB_REWARD_ID,
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
    BaseTheme _bTheme = ThemeManager.of(context).colors;
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
            SizedBox(height: 100.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/images/ad_video.svg",
                  height: 200,
                ),
                Material(
                  shape: CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: _loadingAd == false
                        ? () async {
                            _loadAd(show: true);
                            _showIfAlreadyAvailable();
                          }
                        : null,
                    child: Container(
                      color: _bTheme.contrast,
                      width: 75,
                      height: 75,
                      child: Center(
                        child: _loadingAd == false
                            ? Icon(
                                Icons.play_arrow,
                                size: 50,
                                color: _bTheme.textOnContrast,
                              )
                            : CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                    _bTheme.textOnContrast),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 40,
            ),
            Text(
              'Spiele hier Videos ab und booste deinen Aktivitätsscore!',
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
