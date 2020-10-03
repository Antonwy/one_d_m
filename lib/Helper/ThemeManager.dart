import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeManager extends ChangeNotifier {
  BaseTheme _currentTheme;

  BaseTheme get theme => _currentTheme;
  set theme(BaseTheme theme) {
    _currentTheme = theme;
    notifyListeners();
  }

  ThemeManager() {
    _currentTheme = ThemeHolder.themes[1];
  }

  factory ThemeManager.of(BuildContext context, {bool listen = true}) {
    return Provider.of<ThemeManager>(context, listen: listen);
  }
}

class BaseTheme {
  final Color dark, contrast, light, darkerLight, textOnContrast, textOnDark;

  const BaseTheme(
      {@required this.dark,
      @required this.contrast,
      @required this.light,
      @required this.darkerLight,
      @required this.textOnDark,
      @required this.textOnContrast});
}

class ThemeHolder {
  static BaseTheme orangeBlue = BaseTheme(
    dark: Color.fromARGB(255, 19, 33, 60),
    contrast: Color.fromARGB(255, 252, 163, 16),
    light: Colors.white,
    darkerLight: Color.fromARGB(255, 246, 245, 250),
    textOnDark: Color.fromARGB(255, 19, 33, 60),
    textOnContrast: Colors.white,
  );
  static BaseTheme turqoiseBlue = BaseTheme(
    dark: Color.fromARGB(255, 45, 49, 64),
    contrast: Color.fromARGB(255, 208, 218, 213),
    light: Color.fromARGB(255, 254, 255, 255),
    darkerLight: Color.fromARGB(250, 250, 250, 255),
    textOnDark: Color.fromARGB(255, 254, 255, 255),
    textOnContrast: Color.fromARGB(255, 45, 49, 64),
  );
  static BaseTheme redBlue = BaseTheme(
    dark: Color.fromARGB(255, 43, 45, 66),
    contrast: Color.fromARGB(255, 239, 36, 60),
    light: Colors.white,
    darkerLight: Colors.grey[50],
    textOnDark: Colors.white,
    textOnContrast: Colors.white,
  );
  static BaseTheme darkYellow = BaseTheme(
    dark: Color.fromARGB(255, 38, 70, 83),
    contrast: Color.fromARGB(255, 233, 196, 106),
    light: Colors.white,
    darkerLight: Colors.grey[50],
    textOnDark: Colors.white,
    textOnContrast: Color.fromARGB(255, 37, 36, 34),
  );
  static BaseTheme blueYellow = BaseTheme(
    dark: Color.fromARGB(255, 0, 63, 136),
    contrast: Color.fromARGB(255, 253, 197, 1),
    light: Colors.white,
    darkerLight: Colors.grey[50],
    textOnDark: Colors.white,
    textOnContrast: Color.fromARGB(255, 0, 63, 136),
  );
  static BaseTheme brownRed = BaseTheme(
    dark: Color.fromARGB(255, 37, 36, 34),
    contrast: Color.fromARGB(255, 236, 93, 41),
    light: Color.fromARGB(255, 255, 252, 242),
    darkerLight: Colors.grey[50],
    textOnDark: Colors.white,
    textOnContrast: Colors.white,
  );
  static BaseTheme brownYellow = BaseTheme(
    dark: Color.fromARGB(255, 51, 53, 51),
    contrast: Color.fromARGB(255, 246, 202, 92),
    darkerLight: Colors.grey[50],
    light: Colors.white,
    textOnDark: Colors.white,
    textOnContrast: Colors.white,
  );

  static List<BaseTheme> themes = [
    orangeBlue,
    turqoiseBlue,
    redBlue,
    darkYellow,
    blueYellow,
    brownRed,
    brownYellow
  ];
}
