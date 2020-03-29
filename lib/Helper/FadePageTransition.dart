import 'package:flutter/material.dart';

class FadePageTransition extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  FadePageTransition(this.page,
      {this.duration = const Duration(milliseconds: 250)})
      : super(
            pageBuilder: (context, _, __) => page,
            transitionDuration: duration,
            transitionsBuilder: (context, Animation<double> animation,
                    Animation<double> secondaryAnimation, Widget child) =>
                FadeTransition(
                  opacity: animation,
                  child: child,
                ));
}
