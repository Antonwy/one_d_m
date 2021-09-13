import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ink_page_indicator/ink_page_indicator.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/provider/remote_config_manager.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'margin.dart';

class DialogHolder {
  static Future showWelcomeDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        ThemeManager _theme = ThemeManager.of(context, listen: false);
        ValueNotifier<double> _pageValue = ValueNotifier(0.0);
        PageIndicatorController _controller = new PageIndicatorController();
        _controller.addListener(() {
          _pageValue.value = _controller.page;
        });
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 350,
                width: MediaQuery.of(context).size.width,
                child: PageView(
                  controller: _controller,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          "assets/images/ic_flower.png",
                        ),
                        YMargin(12),
                        Text(
                          "Du hast 3 DV erhalten",
                          style: _theme.textTheme.dark.headline6,
                        ),
                        YMargin(6),
                        Text(
                          "Um mehr DVs zu erhalten, kannst du durch einen Klick auf den Play Button ein Video anschauen. Nach dem anschauen erhälst du einen DV.",
                          style: _theme.textTheme.dark.bodyText2,
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          "assets/icons/ic_donation.png",
                        ),
                        YMargin(12),
                        Text(
                          "Spenden",
                          style: _theme.textTheme.dark.headline6,
                        ),
                        YMargin(6),
                        Text(
                          'Du kannst an Projekt und Sessions spenden indem du den "Unterstützen" Button in der rechten unteren Ecke drückst.',
                          style: _theme.textTheme.dark.bodyText2,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              YMargin(12),
              InkPageIndicator(
                gap: 8,
                padding: 0,
                shape: IndicatorShape.circle(4),
                inactiveColor: ColorTheme.darkblue.withOpacity(.3),
                activeColor: ColorTheme.darkblue,
                inkColor: ColorTheme.darkblue,
                page: _pageValue,
                pageCount: 2,
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.radius)),
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                textColor: _theme.colors.dark,
                child: Text("Verstanden")),
          ],
        );
      },
    );
  }

  static Future showUpdateAppDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        ThemeManager _theme = ThemeManager.of(context, listen: false);
        return AlertDialog(
          title: Text("Es gibt eine neue Version der App!"),
          content: Text(
            "Öffne deinen App Store um  dir die neue Version herunterzuladen!",
            style: _theme.textTheme.dark.bodyText2,
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.radius)),
          actions: <Widget>[
            FlatButton(
                onPressed: () async {
                  SharedPreferences _prefs =
                      await SharedPreferences.getInstance();
                  PackageInfo _info =
                      context.read<RemoteConfigManager>().packageInfo;
                  print(_info);
                  await _prefs.setInt(
                      Constants.UPDATE_DIALOG_DO_NOT_REMIND_AGAIN,
                      int.tryParse(_info.buildNumber) ?? 1);

                  Navigator.pop(context);
                },
                textColor: Colors.red,
                child: Text("Nicht wieder erinnern")),
            FlatButton(
                onPressed: () async {
                  if (await canLaunch(Constants.STORE_LINK)) {
                    await launch(Constants.STORE_LINK);
                  }

                  Navigator.pop(context);
                },
                textColor: _theme.colors.dark,
                child: Text(Platform.isAndroid ? "PlayStore" : "AppStore")),
          ],
        );
      },
    );
  }
}
