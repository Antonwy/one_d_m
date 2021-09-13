import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'margin.dart';

class Empty extends StatelessWidget {
  final String message;

  const Empty({Key key, this.message = "Keine Daten gefunden!"})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset(
          'assets/images/no-news.svg',
          width: 200,
        ),
        YMargin(12),
        Text(message)
      ],
    );
  }
}
