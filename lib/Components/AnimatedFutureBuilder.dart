import 'package:flutter/material.dart';

class AnimatedFutureBuilder<E> extends StatelessWidget {
  Future<E> future;
  Widget Function(BuildContext, AsyncSnapshot<E>) builder;
  Duration duration;
  Curve curve;

  AnimatedFutureBuilder({
    @required this.future,
    @required this.builder,
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
