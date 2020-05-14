import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/CampaignsManager.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/HomePage/HomePage.dart';
import 'package:one_d_m/Pages/VerifyEmailPage.dart';
import 'package:one_d_m/Pages/WelcomeScreen.dart';
import 'package:provider/provider.dart';
import 'package:stripe_payment/stripe_payment.dart';

void main() => runApp(MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => UserManager.instance()),
      ChangeNotifierProvider(create: (context) => CampaignsManager()),
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
      home: Consumer<UserManager>(builder: (context, um, child) {
        switch (um.status) {
          case Status.Uninitialized:
            return Splash();
          case Status.Authenticated:
            return HomePage();
          case Status.Unverified:
            return VerifyEmailPage();
          case Status.Unauthenticated:
          case Status.Authenticating:
            return WelcomeScreen();
          default:
            return Splash();
        }
      }),
    );
  }
}

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 200,
                ),
              ),
            ),
            Center(
                child: Container(
                    height: 160,
                    width: 160,
                    child: CircularProgressIndicator(
                      strokeWidth: 8,
                      valueColor: AlwaysStoppedAnimation(ColorTheme.blue),
                    ))),
          ],
        ),
      ),
    );
  }
}
