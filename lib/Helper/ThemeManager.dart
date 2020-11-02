import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Constants.dart';

class ThemeManager extends ChangeNotifier {
  BaseTheme _currentTheme;
  ThemeData materialTheme;
  MyTextTheme textTheme;

  BaseTheme get colors => _currentTheme;
  set colors(BaseTheme theme) {
    _currentTheme = theme;
    textTheme.updateTheme(theme);
    notifyListeners();
  }

  ThemeManager(BuildContext context) {
    _currentTheme = ThemeHolder.themes[Constants.DEFAULT_THEME_INDEX];
    materialTheme = Theme.of(context);
    textTheme = MyTextTheme(materialTheme.textTheme, _currentTheme);
  }

  factory ThemeManager.of(BuildContext context, {bool listen = true}) {
    return Provider.of<ThemeManager>(context, listen: listen);
  }
}

class MyTextTheme {
  BaseTheme _theme;
  TextTheme _textTheme;
  BaseTextTheme dark, contrast, light, darkerLight, textOnContrast, textOnDark;

  MyTextTheme(this._textTheme, this._theme) {
    dark = BaseTextTheme(_textTheme, _theme.dark);
    contrast = BaseTextTheme(_textTheme, _theme.contrast);
    light = BaseTextTheme(_textTheme, _theme.light);
    darkerLight = BaseTextTheme(_textTheme, _theme.darkerLight);
    textOnContrast = BaseTextTheme(_textTheme, _theme.textOnContrast);
    textOnDark = BaseTextTheme(_textTheme, _theme.textOnDark);
  }

  void updateTheme(BaseTheme theme) {
    _theme = theme;
    dark = BaseTextTheme(_textTheme, _theme.dark);
    contrast = BaseTextTheme(_textTheme, _theme.contrast);
    light = BaseTextTheme(_textTheme, _theme.light);
    darkerLight = BaseTextTheme(_textTheme, _theme.darkerLight);
    textOnContrast = BaseTextTheme(_textTheme, _theme.textOnContrast);
    textOnDark = BaseTextTheme(_textTheme, _theme.textOnDark);
  }
}

class BaseTextTheme {
  final TextTheme _textTheme;
  final Color color;

  const BaseTextTheme(this._textTheme, this.color);

  TextStyle get bodyText1 => _textTheme.bodyText1.copyWith(color: color);
  TextStyle get bodyText2 => _textTheme.bodyText2.copyWith(color: color);
  TextStyle get headline3 => _textTheme.headline3.copyWith(color: color);
  TextStyle get headline5 => _textTheme.headline5.copyWith(color: color);
  TextStyle get headline6 => _textTheme.headline6.copyWith(color: color);
  TextStyle get caption =>
      _textTheme.caption.copyWith(color: color.withOpacity(.6));
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
    textOnDark: Colors.white,
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
