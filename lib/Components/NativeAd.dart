import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:provider/provider.dart';

class NewsNativeAd extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: NativeAdView(
              adUnitId: Constants.ADMOB_NEWS_ID,
              layoutName: "NewsAd",
              onAdImpression: () {
                print("NEW IMPRESSION");
                DatabaseService.addNativeAdImpression(
                  Provider.of<UserManager>(
                    context,
                    listen: false,
                  ).uid,
                );
              },
              onAdClicked: () {},
              onAdFailedToLoad: (Map<String, dynamic> error) =>
                  print("Native ad failed load: $error"),
            ),
          ),
        ),
      ),
    );
  }
}

class ExploreNativeAd extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        clipBehavior: Clip.antiAlias,
        color: ColorTheme.appBg,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: NativeAdView(
                adUnitId: Constants.ADMOB_EXPLORE_ID,
                layoutName: "ExploreAd",
                onAdImpression: () {
                  print("NEW IMPRESSION");
                  DatabaseService.addNativeAdImpression(
                    Provider.of<UserManager>(
                      context,
                      listen: false,
                    ).uid,
                  );
                },
                onAdClicked: () {},
                onAdFailedToLoad: (Map<String, dynamic> error) =>
                    print("onAdFailedToLoad: $error"),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NativeAdView extends StatefulWidget {
  const NativeAdView({
    Key key,
    @required this.adUnitId,
    @required this.layoutName,
    this.onAdImpression,
    this.onAdLeftApplication,
    this.onAdClicked,
    this.onAdFailedToLoad,
    this.onAdLoaded,
  }) : super(key: key);

  final String adUnitId;

  final String layoutName;

  final Function() onAdImpression;

  final Function() onAdLeftApplication;

  final Function() onAdClicked;

  final Function(Map<String, dynamic>) onAdFailedToLoad;

  final Function(double) onAdLoaded;

  @override
  State<StatefulWidget> createState() => _NativeAdViewState();
}

class _NativeAdViewState extends State<NativeAdView>
    with AutomaticKeepAliveClientMixin {
  double height = 600;
  bool failed = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (failed == true) return Container();

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Stack(
        children: [
          Container(
            height: height,
            color: Colors.transparent,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 1.0,
              child: Container(
                height: height,
                width: double.infinity,
                child: UiKitView(
                  viewType: 'native_ads/ad_layout',
                  onPlatformViewCreated: _onPlatformViewCreated,
                  creationParams: {
                    'layout_name': widget.layoutName,
                    'ad_unit_id': widget.adUnitId,
                  },
                  creationParamsCodec: const StandardMessageCodec(),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return Container();
  }

  void _onAdLoaded(double height) {
    setState(() => this.height = height);
    widget.onAdLoaded(height);
  }

  void _onAdFailed(Map<String, dynamic> error) {
    setState(() => failed = true);
    widget.onAdFailedToLoad(error);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onAdImpression':
        widget.onAdImpression();
        break;
      case 'onAdLeftApplication':
        widget.onAdLeftApplication();
        break;
      case 'onAdClicked':
        widget.onAdClicked();
        break;
      case 'onAdFailedToLoad':
        _onAdFailed(Map<String, dynamic>.from(call.arguments));
        break;
      case 'onAdLoaded':
        _onAdLoaded(call.arguments as double);
        break;
    }
  }

  void _onPlatformViewCreated(int id) {
    final MethodChannel channel = MethodChannel('native_ads/ad_layout_$id');
    channel.setMethodCallHandler(_handleMethodCall);
  }
}
