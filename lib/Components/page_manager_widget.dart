import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/components/push_notification.dart';
import 'package:one_d_m/provider/remote_config_manager.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:one_d_m/views/auth/register_page.dart';
import 'package:one_d_m/views/auth/verify_email_page.dart';
import 'package:one_d_m/views/auth/welcome_screen.dart';
import 'package:one_d_m/views/home/home_page.dart';
import 'package:one_d_m/views/maintainance/force_update_screen.dart';
import 'package:provider/provider.dart';

class PageManagerWidget extends StatefulWidget {
  @override
  _PageManagerWidgetState createState() => _PageManagerWidgetState();
}

class _PageManagerWidgetState extends State<PageManagerWidget> {
  bool _shouldLoad = true;
  UserManager _um;
  StreamSubscription _fmStream;
  HomePage _homePage;
  Future<void> _initAppFuture;
  Future<void> _startupFuture;

  @override
  void initState() {
    super.initState();
    _initAppFuture = initializeApp();
    _startupFuture =
        Future.wait([_initAppFuture, Future.delayed(Duration(seconds: 2))]);
    _homePage = HomePage(
      initFuture: _startupFuture,
    );
  }

  @override
  void dispose() {
    if (_fmStream != null) _fmStream.cancel();
    super.dispose();
  }

  Future<void> initializeApp() async {
    RemoteConfigManager _rcm = context.read<RemoteConfigManager>();
    await _rcm.initialize();

    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification notification = message.notification;

      PushNotification.of(context).show(NotificationContent(
        title: notification.title,
        body: notification.body,
      ));
    });

    print("FB-Token: \n${Api.userToken}\n");
  }

  @override
  Widget build(BuildContext context) {
    _um = Provider.of<UserManager>(context);

    if (_um.status == Status.NEEDSMOREINFORMATIONS) {
      return RegisterPage(
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
        future: _startupFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              context.read<RemoteConfigManager>().forceUpdate) {
            return ForceUpdateScreen();
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
                        .copyWith(fontWeight: FontWeight.w600, fontSize: 24)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
