import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/helper/database_service.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:one_d_m/views/auth/choose_login_method.dart';
import 'package:one_d_m/views/general/faq_page.dart';
import 'package:one_d_m/views/home/profile_page.dart';
import 'package:one_d_m/views/users/edit_profile_page.dart';
import 'package:one_d_m/views/users/user_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'custom_open_container.dart';
import 'donation_widget.dart';
import 'loading_indicator.dart';
import 'margin.dart';

class SettingsDialog extends StatefulWidget {
  static Widget builder(BuildContext context) => SettingsDialog();

  @override
  _SettingsDialogState createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late UserManager um;

  late ThemeData _theme;

  @override
  void initState() {
    super.initState();
    context
        .read<FirebaseAnalytics>()
        .setCurrentScreen(screenName: "Settings Dialog");
  }

  @override
  Widget build(BuildContext context) {
    um = Provider.of<UserManager>(context);
    _theme = context.theme;

    return ConstrainedBox(
      constraints: BoxConstraints.loose(
          Size(double.infinity, MediaQuery.of(context).size.height * .9)),
      child: SingleChildScrollView(
        controller: ModalScrollController.of(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 18),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Material(
                          clipBehavior: Clip.antiAlias,
                          borderRadius: BorderRadius.circular(Constants.radius),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (c) => UserPage(
                                            um.user!,
                                          )));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: <Widget>[
                                  Material(
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Container(
                                        child: RoundedAvatar(
                                            um.user?.thumbnailUrl ??
                                                um.user?.imgUrl),
                                        width: 50,
                                        height: 50,
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            Constants.radius + 2)),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "${um.user?.name}",
                                    style: _theme.textTheme.headline6!,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      XMargin(12),
                      AppBarButton(
                        onPressed: () async {
                          String? url = await DatabaseService.getFeedbackUrl();

                          if (url == null) return;

                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            print("Cannot launch url: $url");
                          }
                        },
                        icon: CupertinoIcons.exclamationmark_bubble_fill,
                        color: _theme.canvasColor,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                _GhostSettings(),
                ListTile(
                  title: Text("FAQ"),
                  subtitle: Text("Häufig gestellte Fragen."),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => FaqPage()));
                  },
                ),
                ListTile(
                  title: Text("Profil Einstellungen"),
                  subtitle: Text("${um.user?.name}"),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                  onTap: () async {
                    final editProfile = EditProfile();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => editProfile));
                  },
                ),
                SwitchListTile(
                    title: Text("Push Benachrichtigungen"),
                    value: um.user?.deviceToken != null,
                    activeColor: _theme.primaryColor,
                    onChanged: (val) => _togglePushNotifications(val, um: um)),
                ListTile(
                  title: Text("Datenschutzbedingungen"),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                  onTap: () {
                    launchUrl(Constants.DATENSCHUTZ);
                  },
                ),
                ListTile(
                  title: Text("Nutzungsbedingungen"),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                  onTap: () async {
                    launchUrl(Constants.NUTZUNGSBEDINGUNGEN);
                  },
                ),
                _LogoutSetting(),
                SizedBox(
                  height: 10 + MediaQuery.of(context).padding.bottom,
                )
              ]),
        ),
      ),
    );
  }

  void launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void _togglePushNotifications(bool val, {required UserManager um}) async {
    final PermissionStatus permission = await Permission.notification.status;

    print(val);

    if (val) {
      if (permission != PermissionStatus.granted) {
        print(permission);
        final PermissionStatus status = await Permission.notification.request();

        print(status);

        if (status == PermissionStatus.granted)
          await _saveToken(um);
        else
          openAppSettings();
      } else
        await _saveToken(um);
    } else {
      await Api().account().deleteDeviceToken();
      await um.reloadUser();
    }
  }

  Future<void> _saveToken(UserManager um) async {
    String? token = await FirebaseMessaging.instance.getToken();
    await Api().account().saveDeviceToken(token);
    await um.reloadUser();
  }
}

class _GhostSettings extends StatefulWidget {
  @override
  __GhostSettingsState createState() => __GhostSettingsState();
}

class __GhostSettingsState extends State<_GhostSettings> {
  bool _loading = false, _error = false;

  @override
  Widget build(BuildContext context) {
    UserManager um = context.watch<UserManager>();
    bool isGhost = um.user?.ghost ?? false;
    return ListTile(
      title: Text("Ghost Modus"),
      subtitle: Text("${isGhost ? "Niemand" : "Jeder"} kann dein Profil sehen"),
      trailing: _trailing(isGhost),
      onTap: () async {
        if (await showGhostDialog(context, isGhost) ?? false) {
          setState(() {
            _loading = true;
          });
          try {
            await Api().account().updateMap({"ghost": !isGhost});
            await um.reloadUser();
          } catch (e) {
            setState(() {
              _error = true;
            });
          }
          _loading = false;
        }
      },
    );
  }

  Widget _trailing(bool isGhost) {
    if (_error)
      return Icon(
        Icons.warning,
        size: 18,
      );

    if (_loading)
      return LoadingIndicator(
          size: 16, color: Colors.grey[800], strokeWidth: 2);

    return Icon(
      isGhost ? CupertinoIcons.eye_slash_fill : CupertinoIcons.eye_fill,
      size: 18,
    );
  }

  Future<bool?> showGhostDialog(BuildContext context, bool currentGhost) {
    return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Constants.radius)),
              title: Text("Ghost Modus"),
              content: Text(
                  "Bist du dir sicher, dass du den Ghost Modus ${currentGhost ? "ausschalten" : "anschalten"} willst?\n\n${currentGhost ? "Wenn der Ghost Modus ausgeschaltet ist, kann dich jeder finden!" : "Wenn der Ghost modus eingeschaltet ist, kann dich niemand finden!"}"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: Text("Abbrechen")),
                TextButton(
                    style: TextButton.styleFrom(
                        primary: Theme.of(context).colorScheme.secondary),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: Text(currentGhost ? "Ausschalten" : "Anschalten")),
              ],
            ));
  }
}

class _LogoutSetting extends StatefulWidget {
  @override
  __LogoutSettingState createState() => __LogoutSettingState();
}

class __LogoutSettingState extends State<_LogoutSetting> {
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    UserManager um = context.read<UserManager>();
    return ListTile(
      title: Text("Logout"),
      trailing: _loading
          ? LoadingIndicator(size: 16, color: Colors.grey[800], strokeWidth: 2)
          : Icon(
              CupertinoIcons.power,
              size: 24,
            ),
      onTap: () async {
        setState(() {
          _loading = true;
        });
        await um.logout();

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (c) => ChooseLoginMethodPage()),
            (route) => route.isFirst);
      },
    );
  }
}
