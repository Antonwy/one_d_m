import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/PushNotification.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/NewRegisterPage.dart';
import 'package:provider/provider.dart';
import 'package:one_d_m/Helper/margin.dart';

import 'HomePage/HomePage.dart';
import 'VerifyEmailPage.dart';
import 'WelcomeScreen.dart';

class PageManagerWidget extends StatefulWidget {
  @override
  _PageManagerWidgetState createState() => _PageManagerWidgetState();
}

class _PageManagerWidgetState extends State<PageManagerWidget> {
  bool _shouldLoad = true;
  UserManager _um;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  StreamSubscription _fmStream;
  bool _saveToken = false;
  HomePage _homePage;

  @override
  void initState() {
    super.initState();
    _homePage = HomePage();
    _fmStream = _firebaseMessaging.onIosSettingsRegistered.listen((data) {
      print(data);
      _saveToken = true;
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        PushNotification.of(context)
            .show(NotificationContent.fromMessage(message));
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // TODO optional
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // TODO optional
      },
    );
  }

  Future<void> _saveDeviceToken() async {
    await DatabaseService.saveDeviceToken(
        _um.uid, await _firebaseMessaging.getToken());
  }

  @override
  void dispose() {
    if (_fmStream != null) _fmStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _um = Provider.of<UserManager>(context);

    if (_um.status == Status.NEEDSMOREINFORMATIONS) {
      return NewRegisterPage(
        socialSignIn: true,
      );
    }

    if (_um.status == Status.Authenticating ||
        _um.status == Status.Unauthenticated) {
      return WelcomeScreen();
    }

    if (_um.status == Status.Unverified) return VerifyEmailPage();

    if (!_shouldLoad) {
      return _homePage;
    }

    if (_um.status == Status.Authenticated) {
      _shouldLoad = false;
    }

    return FutureBuilder(
        future: Future.delayed(Duration(milliseconds: 2000)),
        builder: (context, snapshot) {
          if (_saveToken && _um?.uid != null) {
            _saveDeviceToken();
          }

          return Stack(
            children: <Widget>[
              _um?.uid == null
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : _homePage,
              _HideSplash(snapshot.connectionState == ConnectionState.done)
            ],
          );
        });
  }
}

class _HideSplash extends StatefulWidget {
  final bool _hide;

  _HideSplash(this._hide);

  @override
  __HideSplashState createState() => __HideSplashState();
}

class __HideSplashState extends State<_HideSplash> {
  bool _hideSplash = false;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
        child: IgnorePointer(
            ignoring: widget._hide,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              onEnd: () {
                setState(() {
                  _hideSplash = true;
                });
              },
              opacity: widget._hide ? 0 : 1,
              child: _hideSplash ? Container() : Splash(),
            )));
  }
}

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return Material(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                        parent: _controller,
                        curve: Interval(.3, 1.0, curve: Curves.easeOut))),
                child: Image.asset(
                  'assets/images/ic_onedm.png',
                  width: 250,
                  height: 200,
                ),
              ),
              FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                        parent: _controller,
                        curve: Interval(.3, 1.0, curve: Curves.easeOut))),
                child: AutoSizeText("One Dollar Movement",
                    maxLines: 1,
                    style: _theme.textTheme.dark.headline5
                        .copyWith(fontWeight: FontWeight.w600,fontSize: 24)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
