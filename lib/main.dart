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
      ChangeNotifierProvider(create: (context) => ThemeManager()),
      Provider(
        create: (context) => PushNotificationService(context),
      )
    ], child: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    StripePayment.setOptions(
        StripeOptions(publishableKey: Constants.STRIPE_TEST_KEY));
    getThemeIndex().then((value) {
      ThemeManager.of(context, listen: false).theme = ThemeHolder.themes[value];
    });
    NativeAds.initialize();
    FirebaseAdMob.instance.initialize(appId: "ca-app-pub-3940256099942544~1458002511");
    StripePayment.setOptions(StripeOptions(
        publishableKey: "pk_test_mMYl6nvlrQmibKbJWw3CsdoK00lcfXjNKW"));
    super.initState();
  }

  Future<int> getThemeIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(Constants.THEME_KEY) ?? 0;
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
