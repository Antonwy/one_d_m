import 'package:flutter/material.dart';

class AnimatedFutureBuilder<E> extends StatelessWidget {
  final Future<E> future;
  final Widget Function(BuildContext, AsyncSnapshot<E>) builder;
  final Duration duration;
  final Curve curve;

  AnimatedFutureBuilder({
    required this.future,
    required this.builder,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.fastLinearToSlowEaseIn,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<E>(
        future: future,
        builder: (context, snapshot) {
          return AnimatedSwitcher(
            duration: duration,
            child: builder(context, snapshot),
            switchInCurve: curve,
            switchOutCurve: curve,
          );
        });
  }
}
