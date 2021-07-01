import 'package:flutter/material.dart';

import 'Helper.dart';

class ColorTheme {
  static const Color black = Color.fromARGB(255, 0, 0, 0);
  static const Color white = Color.fromARGB(255, 255, 255, 255);

  static const Color blue = Color.fromARGB(255, 19, 33, 60);
  static const Color orange = Color.fromARGB(255, 252, 163, 16);
  static const Color green = Color.fromARGB(255, 0, 191, 166);
  static const Color yellow = Color.fromARGB(255, 253, 205, 89);
  static Color appGrey = Helper.hexToColor('#d1d9d5');
  static Color appDarkGrey = Helper.hexToColor('#2e313f');
  static const Color appBg = Color.fromARGB(255, 245, 245, 245);

  static const Color lightBlue = Color.fromARGB(255, 246, 245, 250);
  static const Color whiteBlue = Color.fromARGB(255, 246, 245, 250);
  static const Color lightGrey = Color.fromARGB(255, 246, 245, 250);

  static const Color darkOrange = Color.fromARGB(255, 255, 100, 86);
  static const Color wildGreen = Color(0xFF2A6654);
  static const Color darkblue = Color.fromARGB(255, 45, 49, 64);
  static Color donationBlue = Helper.hexToColor('#457b9d');
  static Color donationLightBlue = Helper.hexToColor('#a8dadc');
  static Color donationRed = Helper.hexToColor('#e63946');

  static const Color homePage = white;
  static const Color navBar = whiteBlue;
  static const Color navBarHighlight = blue;
  static const Color navBarDisabled = Color.fromARGB(150, 19, 33, 60);
  static const Color percentSlider = orange;
  static const Color profilePageRoundButton = orange;
  static const Color donationWidget = blue;
  static const Color donationWidgetText = whiteBlue;
  static const Color textOnDark = white;
  static const Color avatar = blue;
}
