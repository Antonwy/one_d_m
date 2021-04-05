import 'dart:io';
import 'package:catcher/core/catcher.dart';
import 'package:catcher/handlers/console_handler.dart';
import 'package:catcher/handlers/sentry_handler.dart';
import 'package:catcher/mode/silent_report_mode.dart';
import 'package:catcher/model/catcher_options.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/AdManager.dart';
import 'package:one_d_m/Helper/Donation.dart';
import 'package:one_d_m/Helper/NativeAds.dart';
import 'package:one_d_m/Helper/PushNotificationService.dart';
import 'package:one_d_m/Helper/RemoteConfigManager.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/NewCampaignPage.dart';
import 'package:provider/provider.dart';
import 'package:sentry/sentry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stripe_payment/stripe_payment.dart';

import 'Helper/Campaign.dart';
import 'Helper/Constants.dart';
import 'Pages/PageManagerWidget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  /// Debug configuration with dialog report mode and console handler. It will show dialog and once user accepts it, error will be shown   /// in console.
  CatcherOptions debugOptions =
      CatcherOptions(SilentReportMode(), [ConsoleHandler()]);

  /// Release configuration. Same as above, but once user accepts dialog, user will be prompted to send email with crash to support.
  CatcherOptions releaseOptions = CatcherOptions(SilentReportMode(), [
    SentryHandler(SentryClient(SentryOptions(
        dsn:
            'https://a7d6cef66d684048a5b9e4e4c6f10bbc@o508671.ingest.sentry.io/5601525')))
  ]);

  Catcher(
      rootWidget: MultiProvider(providers: [
        ChangeNotifierProvider(create: (context) => UserManager.instance()),
        ChangeNotifierProvider(create: (context) => ThemeManager(context)),
        Provider(
          create: (context) => PushNotificationService(context),
        ),
        Provider(
          create: (context) => RemoteConfigManager(),
        ),
      ], child: ODMApp()),
      debugConfig: debugOptions,
      releaseConfig: releaseOptions);
}

class ODMApp extends StatefulWidget {
  @override
  _ODMAppState createState() => _ODMAppState();
}

class _ODMAppState extends State<ODMApp> {
  @override
  void initState() {
    StripePayment.setOptions(
        StripeOptions(publishableKey: Constants.STRIPE_LIVE_KEY));
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
    return MaterialApp(
        navigatorKey: Catcher.navigatorKey,
        title: 'One Dollar Movement',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: AppBarTheme(brightness: Brightness.light),
          primarySwatch: Colors.indigo,
        ),
        home: PageManagerWidget());
  }
}
