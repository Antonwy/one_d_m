import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Helper/Constants.dart';
import 'package:provider/provider.dart';

class ThemeManager extends ChangeNotifier {
  late BaseTheme _currentTheme;
  late ThemeData materialTheme;
  late MyTextTheme textTheme;

  ThemeMode themeMode = ThemeMode.system;
  Future<void> setThemeMode(ThemeMode mode, {bool withSave = true}) async {
    themeMode = mode;

    if (withSave) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt(Constants.THEME_KEY, mode.index);
    }

    notifyListeners();
  }

  BaseTheme get colors => _currentTheme;
  set colors(BaseTheme theme) {
    _currentTheme = theme;
    textTheme.updateTheme(theme);
    notifyListeners();
  }

  Color correctColorFor(Color color) =>
      ThemeData.estimateBrightnessForColor(color) == Brightness.dark
          ? _currentTheme.light
          : _currentTheme.dark;

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

  BaseTextTheme correctColorFor(Color color) =>
      ThemeData.estimateBrightnessForColor(color) == Brightness.dark
          ? light
          : dark;

  MyTextTheme(this._textTheme, this._theme)
      : dark = BaseTextTheme(_textTheme, _theme.dark),
        contrast = BaseTextTheme(_textTheme, _theme.contrast),
        light = BaseTextTheme(_textTheme, _theme.light),
        darkerLight = BaseTextTheme(_textTheme, _theme.darkerLight),
        textOnContrast = BaseTextTheme(_textTheme, _theme.textOnContrast),
        textOnDark = BaseTextTheme(_textTheme, _theme.textOnDark);

  void updateTheme(BaseTheme theme) {
    _theme = theme;
    dark = BaseTextTheme(_textTheme, _theme.dark);
    contrast = BaseTextTheme(_textTheme, _theme.contrast);
    light = BaseTextTheme(_textTheme, _theme.light);
    darkerLight = BaseTextTheme(_textTheme, _theme.darkerLight);
    textOnContrast = BaseTextTheme(_textTheme, _theme.textOnContrast);
    textOnDark = BaseTextTheme(_textTheme, _theme.textOnDark);
  }

  BaseTextTheme withColor(Color color) {
    return BaseTextTheme(_textTheme, color);
  }
}

class BaseTextTheme {
  final TextTheme _textTheme;
  final Color color;

  const BaseTextTheme(this._textTheme, this.color);

  TextStyle get bodyText1 => _textTheme.bodyText1!.copyWith(color: color);
  TextStyle get bodyText2 => _textTheme.bodyText2!.copyWith(color: color);
  TextStyle get headline3 => _textTheme.headline3!.copyWith(color: color);
  TextStyle get headline5 => _textTheme.headline5!.copyWith(color: color);
  TextStyle get headline6 => _textTheme.headline6!.copyWith(color: color);
  TextStyle get caption =>
      _textTheme.caption!.copyWith(color: color.withOpacity(.6));

  BaseTextTheme withOpacity(double opacity) =>
      BaseTextTheme(this._textTheme, color.withOpacity(opacity));
}

class BaseTheme {
  final Color dark,
      contrast,
      accent,
      light,
      darkerLight,
      textOnContrast,
      textOnDark,
      background;

  const BaseTheme(
      {required this.dark,
      required this.contrast,
      required this.accent,
      required this.light,
      required this.darkerLight,
      required this.textOnDark,
      required this.textOnContrast,
      required this.background});
}

class ThemeHolder {
  static BaseTheme turqoiseBlue = BaseTheme(
    dark: Color.fromARGB(255, 45, 49, 64),
    contrast: Color.fromARGB(255, 208, 218, 213),
    accent: Color.fromARGB(255, 208, 218, 213),
    light: Color.fromARGB(255, 254, 255, 255),
    darkerLight: Color.fromARGB(250, 250, 250, 255),
    textOnDark: Color.fromARGB(255, 254, 255, 255),
    textOnContrast: Color.fromARGB(255, 45, 49, 64),
    background: Colors.white,
  );
  static BaseTheme light = BaseTheme(
    dark: Color.fromARGB(255, 44, 44, 46),
    contrast: Color.fromARGB(255, 229, 229, 234),
    accent: Color.fromARGB(255, 10, 132, 255),
    light: Color.fromARGB(255, 254, 255, 255),
    darkerLight: Color.fromARGB(250, 250, 250, 255),
    textOnDark: Color.fromARGB(255, 254, 255, 255),
    textOnContrast: Color.fromARGB(255, 45, 49, 64),
    background: Colors.white,
  );
  static BaseTheme dark = BaseTheme(
    dark: Color.fromARGB(255, 44, 44, 46),
    contrast: Color.fromARGB(255, 229, 229, 234),
    accent: Color.fromARGB(255, 10, 132, 255),
    light: Color.fromARGB(255, 254, 255, 255),
    darkerLight: Color.fromARGB(250, 250, 250, 255),
    textOnDark: Color.fromARGB(255, 254, 255, 255),
    textOnContrast: Color.fromARGB(255, 45, 49, 64),
    background: Colors.black,
  );

  static List<BaseTheme> themes = [
    turqoiseBlue,
    dark,
    light,
  ];
}
