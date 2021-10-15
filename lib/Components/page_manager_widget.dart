import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/components/push_notification.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:one_d_m/helper/dynamic_link_manager.dart';
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
  late HomePage _homePage;
  late Future<void> _initAppFuture;
  Future<void>? _startupFuture;

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

  Future<void> initializeApp() async {
    RemoteConfigManager _rcm = context.read<RemoteConfigManager>();
    await _rcm.initialize();

    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification notification = message.notification!;

      PushNotification.of(context).show(NotificationContent(
        title: notification.title ?? "Neue Nachricht",
        body: notification.body,
      ));
    });

    print("FB-Token: \n${Api.userToken}\n");
  }

  @override
  Widget build(BuildContext context) {
    UmSelector umS = context.select<UserManager, UmSelector>(
        (value) => UmSelector(value.status, value.uid));

    if (umS.status == Status.NEEDSMOREINFORMATIONS) {
      return RegisterPage(
        socialSignIn: true,
      );
    }

    if (umS.status == Status.Authenticating ||
        umS.status == Status.Unauthenticated) {
      return WelcomeScreen();
    }

    if (umS.status == Status.Unverified) return VerifyEmailPage();

    print(umS.status);
    return FutureBuilder(
        future: _startupFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              context.read<RemoteConfigManager>().forceUpdate) {
            return ForceUpdateScreen();
          }

          return Stack(
            children: <Widget>[
              if (umS.uid != null) _homePage,
              _HideSplash(snapshot.connectionState == ConnectionState.done &&
                  umS.uid != null)
            ],
          );
        });
  }
}

class UmSelector {
  final Status status;
  final String? uid;

  UmSelector(this.status, this.uid);
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
  late AnimationController _controller;

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
    return Material(
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
                    style: context.theme.textTheme.headline5!
                        .copyWith(fontWeight: FontWeight.w600, fontSize: 24)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
