import 'dart:io';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/not_used/push_notification_service.dart';
import 'package:one_d_m/provider/statistics_manager.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:stripe_payment/stripe_payment.dart';
import 'Helper/Constants.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'api/api.dart';
import 'components/page_manager_widget.dart';
import 'helper/ad_manager.dart';
import 'helper/native_ads.dart';
import 'provider/remote_config_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await Api().init();

  timeago.setLocaleMessages('de', timeago.DeMessages());

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => UserManager.instance()),
    ChangeNotifierProvider(create: (context) => ThemeManager(context)),
    ChangeNotifierProvider(create: (context) => StatisticsManager()),
    Provider(
      create: (context) => PushNotificationService(context),
    ),
    Provider(
      create: (context) => RemoteConfigManager(),
    ),
    Provider(
      create: (context) => FirebaseAnalytics(),
    )
  ], child: ODMApp()));
}

class ODMApp extends StatefulWidget {
  @override
  _ODMAppState createState() => _ODMAppState();
}

class _ODMAppState extends State<ODMApp> {
  @override
  void initState() {
    // StripePayment.setOptions(
    //     StripeOptions(publishableKey: Constants.STRIPE_LIVE_KEY));
    getThemeIndex().then((value) {
      ThemeManager.of(context, listen: false).colors =
          ThemeHolder.themes[value];
    });
    Platform.isAndroid ? NativeAds.initialize() : null;
    FirebaseAdMob.instance.initialize(appId: AdManager.appId);
    super.initState();
  }

  Future<int> getThemeIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(Constants.THEME_KEY) ?? Constants.DEFAULT_THEME_INDEX;
  }

  @override
  Widget build(BuildContext context) {
    return FeatureDiscovery(
      child: MaterialApp(
          title: 'One Dollar Movement',
          debugShowCheckedModeBanner: false,
          navigatorObservers: [
            FirebaseAnalyticsObserver(
                analytics: context.read<FirebaseAnalytics>()),
          ],
          theme: ThemeData(
            appBarTheme: AppBarTheme(brightness: Brightness.light),
            primarySwatch: Colors.indigo,
          ),
          home: PageManagerWidget()),
    );
  }
}
