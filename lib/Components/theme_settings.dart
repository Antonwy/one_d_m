import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:provider/provider.dart';

extension ThemeModeNames on ThemeMode {
  String get name {
    switch (this) {
      case ThemeMode.dark:
        return "Dark";
      case ThemeMode.light:
        return "Light";
      case ThemeMode.system:
        return "System";
      default:
        return "Dark";
    }
  }
}

class ThemeSettings extends StatefulWidget {
  ThemeSettings({Key? key}) : super(key: key);

  @override
  State<ThemeSettings> createState() => _ThemeSettingsState();
}

class _ThemeSettingsState extends State<ThemeSettings> {
  final Map<ThemeMode, Widget> _items = {};

  @override
  void initState() {
    ThemeMode.values.forEach((mode) {
      _items[mode] = Text(mode.name);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeManager manager = context.watch<ThemeManager>();

    return ListTile(
      title: Text("Theme"),
      subtitle: Text(manager.themeMode.name),
      trailing: PopupMenuButton<ThemeMode>(
          tooltip: "Wähle Theme",
          // child: Text(manager.themeMode.name),
          child: Icon(Icons.color_lens),
          initialValue: manager.themeMode,
          onSelected: manager.setThemeMode,
          itemBuilder: (context) => ThemeMode.values
              .map((mode) =>
                  PopupMenuItem<ThemeMode>(value: mode, child: Text(mode.name)))
              .toList()),

      // CupertinoSlidingSegmentedControl<ThemeMode>(
      //   groupValue: manager.themeMode,
      //   children: _items,
      //   onValueChanged: (mode) => manager.setThemeMode(mode!),
      // ),
    );
  }
}
