import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

extension ThemeContext on BuildContext {
  ThemeData get theme {
    return Theme.of(this);
  }
}

extension OpacityStyle on TextStyle {
  TextStyle withOpacity(double val) =>
      this.copyWith(color: color?.withOpacity(val));
}

extension CustomTheme on ThemeData {
  bool get darkMode => brightness == Brightness.dark;
  Color correctColorFor(Color color) =>
      ThemeData.estimateBrightnessForColor(color) == Brightness.dark
          ? Colors.white
          : Colors.black;
}

extension TextColor on Color {
  Color get textColor =>
      ThemeData.estimateBrightnessForColor(this) == Brightness.dark
          ? Colors.white
          : Colors.black;
}

extension SystemOverlay on BuildContext {
  SystemUiOverlayStyle get systemOverlayStyle => this.theme.darkMode
      ? SystemUiOverlayStyle.light
      : SystemUiOverlayStyle.dark;
}
