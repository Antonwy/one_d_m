import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
        ThemeData _theme = Theme.of(context);

        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: SvgPicture.asset("assets/images/welcome-gift.svg",
                          height: 100),
                    ),
                    YMargin(24),
                    Text(
                      "Du hast 3 DV erhalten",
                      style: _theme.textTheme.headline6,
                    ),
                    YMargin(6),
                    Text(
                      "Um mehr DVs zu erhalten, kannst du durch einen Klick auf den Play Button ein Video anschauen. Nach dem anschauen erhälst du einen DV.",
                      style: _theme.textTheme.bodyText2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.radius)),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
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
        ThemeData _theme = Theme.of(context);
        return AlertDialog(
          title: Text("Es gibt eine neue Version der App!"),
          content: Text(
            "Öffne deinen App Store um  dir die neue Version herunterzuladen!",
            style: _theme.textTheme.bodyText2,
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.radius)),
          actions: <Widget>[
            TextButton(
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
                style: TextButton.styleFrom(primary: _theme.errorColor),
                child: Text("Nicht wieder erinnern")),
            TextButton(
                onPressed: () async {
                  if (await canLaunch(Constants.STORE_LINK)) {
                    await launch(Constants.STORE_LINK);
                  }

                  Navigator.pop(context);
                },
                child: Text(Platform.isAndroid ? "PlayStore" : "AppStore")),
          ],
        );
      },
    );
  }
}
