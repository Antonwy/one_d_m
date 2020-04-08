import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/CampaignsManager.dart';
import 'package:one_d_m/Helper/PageManager.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/HomePage/HomePage.dart';
import 'package:one_d_m/Pages/RegisterPage.dart';
import 'package:provider/provider.dart';

void main() => runApp(MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => UserManager.instance()),
      ChangeNotifierProvider(create: (context) => CampaignsManager()),
      ChangeNotifierProvider(create: (context) => PageManager()),
    ], child: MyApp()));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'One Dollar Movement',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: Consumer<UserManager>(builder: (context, um, child) {
        switch (um.status) {
          case Status.Uninitialized:
            return Splash();
          case Status.Authenticated:
            return HomePage();
          case Status.Unauthenticated:
          case Status.Authenticating:
            return RegisterPage();
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
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
