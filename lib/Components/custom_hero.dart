import 'package:flutter/material.dart';

class CustomHero extends StatelessWidget {
  final String tag;
  final HeroFlightShuttleBuilder flightShuttleBuilder;
  final Widget child;

  const CustomHero({Key key, this.tag, this.flightShuttleBuilder, this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
        tag: tag, flightShuttleBuilder: flightShuttleBuilder, child: child);
  }
}
