import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';

class NoInternet extends StatelessWidget {
  const NoInternet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset("assets/images/no-internet.svg", height: 150),
        YMargin(24),
        Text("Keine Verbindung zum Internet!",
            style: context.theme.textTheme.bodyText1)
      ],
    );
  }
}
