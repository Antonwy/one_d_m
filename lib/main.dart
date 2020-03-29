import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/HomePage/HomePage.dart';
import 'package:one_d_m/Pages/RegisterPage.dart';
import 'package:provider/provider.dart';

void main() => runApp(ChangeNotifierProvider(
    create: (context) => UserManager.instance(), child: MyApp()));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'One Dollar Movement',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: Consumer<UserManager>(builder: (context, um, child) {
        print(um.status);
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
