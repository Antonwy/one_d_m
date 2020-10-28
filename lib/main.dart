import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/NativeAds.dart';
import 'package:one_d_m/Helper/PushNotificationService.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stripe_payment/stripe_payment.dart';

import 'Helper/Constants.dart';
import 'Pages/PageManagerWidget.dart';

void main() => runApp(MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => UserManager.instance()),
      ChangeNotifierProvider(create: (context) => ThemeManager(context)),
      Provider(
        create: (context) => PushNotificationService(context),
      )
    ], child: ODMApp()));

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
    NativeAds.initialize();
    FirebaseAdMob.instance.initialize(appId: Constants.ADMOB_APP_ID);
    super.initState();
  }

  Future<int> getThemeIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(Constants.THEME_KEY) ?? Constants.DEFAULT_THEME_INDEX;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'One Dollar Movement',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: AppBarTheme(brightness: Brightness.light),
          primarySwatch: Colors.indigo,
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
          }),
        ),
        home: PageManagerWidget());
  }
}
