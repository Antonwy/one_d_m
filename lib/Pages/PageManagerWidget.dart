import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/Components/PushNotification.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/NewRegisterPage.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
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
    print("SAVING DEVICE TOKEN");
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
    final HomePage _homePage = HomePage();
    print("BUILD MANAGER");
    print(_um.status);
    print(_shouldLoad);

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
        future: Future.delayed(Duration(milliseconds: 1500)),
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
              Positioned.fill(
                  child: IgnorePointer(
                      ignoring:
                          snapshot.connectionState != ConnectionState.waiting,
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 500),
                        opacity:
                            snapshot.connectionState == ConnectionState.waiting
                                ? 1
                                : 0,
                        child: Splash(),
                      )))
            ],
          );
        });
  }
}

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  SvgPicture picture;

  @override
  void initState() {
    picture = SvgPicture.asset(
      'assets/images/odm-logo.svg',
      height: 130,
      width: 130,
    );
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
    return Material(
      color: ColorTheme.whiteBlue,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(_controller),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                  CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
              child: SlideTransition(
                position: Tween<Offset>(begin: Offset(0, .4), end: Offset.zero)
                    .animate(CurvedAnimation(
                        parent: _controller, curve: Curves.easeOut)),
                child: picture,
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                    parent: _controller,
                    curve: Interval(.3, 1.0, curve: Curves.easeOut))),
            child: SlideTransition(
              position: Tween<Offset>(begin: Offset(0, 1.5), end: Offset.zero)
                  .animate(CurvedAnimation(
                      parent: _controller,
                      curve: Interval(.3, 1.0, curve: Curves.easeOut))),
              child: Text(
                "One Dollar Movement",
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(color: ColorTheme.blue),
              ),
            ),
          )
        ],
      ),
    );
  }
}
