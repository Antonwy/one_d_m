import 'package:flutter/material.dart';

class CustomHero extends StatelessWidget {
  final String tag;
  final HeroFlightShuttleBuilder? flightShuttleBuilder;
  final Widget child;
  final bool disabled;

  const CustomHero(
      {Key? key,
      required this.tag,
      this.flightShuttleBuilder,
      required this.child,
      this.disabled = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return disabled
        ? Container(
            child: child,
          )
        : Hero(
            tag: tag, flightShuttleBuilder: flightShuttleBuilder, child: child);
  }
}
