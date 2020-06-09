import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/CampaignsManager.dart';
import 'package:one_d_m/Helper/PushNotificationService.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:provider/provider.dart';
import 'package:stripe_payment/stripe_payment.dart';

import 'Pages/PageManagerWidget.dart';

void main() => runApp(MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => UserManager.instance()),
      ChangeNotifierProvider(create: (context) => CampaignsManager()),
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
    StripePayment.setOptions(StripeOptions(
        publishableKey: "pk_test_mMYl6nvlrQmibKbJWw3CsdoK00lcfXjNKW"));
    super.initState();
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
