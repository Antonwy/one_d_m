import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:one_d_m/Components/CustomOpenContainer.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:one_d_m/Pages/ChooseLoginMethodPage.dart';
import 'package:one_d_m/Pages/EditProfile.dart';
import 'package:one_d_m/Pages/FaqPage.dart';
import 'package:one_d_m/Pages/UserPage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'DonationWidget.dart';

class SettingsDialog extends StatefulWidget {
  static Widget builder(BuildContext context) => SettingsDialog();

  @override
  _SettingsDialogState createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  UserManager um;

  TextTheme _textTheme;

  @override
  Widget build(BuildContext context) {
    um = Provider.of<UserManager>(context);
    _textTheme = Theme.of(context).accentTextTheme;
    ThemeManager _theme = ThemeManager.of(context);
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
                        child: CustomOpenContainer(
                          openBuilder: (context, close, controller) =>
                              UserPage(um.user, scrollController: controller),
                          closedElevation: 0,
                          closedColor: ColorTheme.whiteBlue,
                          closedBuilder: (context, open) => Material(
                            borderRadius:
                                BorderRadius.circular(Constants.radius),
                            clipBehavior: Clip.antiAlias,
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: open,
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
                                      color: _theme.colors.contrast,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              Constants.radius + 2)),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "${um.user?.name}",
                                      style: _textTheme.headline6
                                          .copyWith(color: ColorTheme.blue),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      XMargin(12),
                      Material(
                        color: ColorTheme.appBg,
                        borderRadius: BorderRadius.circular(Constants.radius),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                            onTap: () async {
                              String url =
                                  await DatabaseService.getFeedbackUrl();

                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                print("Cannot launch url: $url");
                              }
                            },
                            child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  CupertinoIcons.exclamationmark_bubble_fill,
                                  color: ThemeManager.of(context).colors.dark,
                                ))),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Consumer<ThemeManager>(builder: (context, tm, child) {
                    BaseTheme currentTheme = tm.colors;
                    return AnimatedContainer(
                        duration: Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                            color: currentTheme.contrast,
                            borderRadius: BorderRadius.circular(6)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 12.0, bottom: 12),
                                child: AnimatedDefaultTextStyle(
                                  duration: Duration(milliseconds: 250),
                                  style: _textTheme.bodyText1.copyWith(
                                      color: currentTheme.textOnContrast),
                                  child: Text(
                                    "App Theme",
                                  ),
                                ),
                              ),
                              Container(
                                height: 50,
                                child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: ThemeHolder.themes.length,
                                    separatorBuilder: (context, index) =>
                                        VerticalDivider(),
                                    itemBuilder: (context, index) {
                                      BaseTheme bTheme =
                                          ThemeHolder.themes[index];
                                      bool isSelected = currentTheme == bTheme;
                                      return Padding(
                                        padding: EdgeInsets.only(
                                            left: index == 0 ? 12.0 : 0,
                                            right: index ==
                                                    ThemeHolder.themes.length -
                                                        1
                                                ? 12.0
                                                : 0),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Material(
                                            elevation: isSelected ? 2 : 0,
                                            clipBehavior: Clip.antiAlias,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Constants.radius)),
                                            child: InkWell(
                                                onTap: () async {
                                                  _theme.colors = bTheme;
                                                  SharedPreferences prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  prefs.setInt(
                                                      Constants.THEME_KEY,
                                                      index);
                                                },
                                                child: Container(
                                                  height: 42,
                                                  width: 42,
                                                  color: bTheme.dark,
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        width: 42,
                                                        height: 21,
                                                        color: bTheme.dark,
                                                      ),
                                                      Container(
                                                        width: 42,
                                                        height: 21,
                                                        color: bTheme.contrast,
                                                      ),
                                                    ],
                                                  ),
                                                )),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ],
                          ),
                        ));
                  }),
                ),
                SizedBox(height: 10),
                StreamBuilder<bool>(
                    stream: DatabaseService.isGhost(um.uid),
                    initialData: false,
                    builder: (context, snapshot) {
                      bool isGhost = snapshot.data ?? false;
                      return ListTile(
                        title: Text("Ghost Modus"),
                        subtitle: Text(
                            "${isGhost ? "Niemand" : "Jeder"} kann dein Profil sehen"),
                        trailing: Icon(
                          isGhost
                              ? CupertinoIcons.eye_slash_fill
                              : CupertinoIcons.eye_fill,
                          size: 18,
                        ),
                        onTap: () async {
                          if (await showGhostDialog(context, isGhost) ?? false)
                            DatabaseService.toggleGhost(um.uid, !isGhost);
                        },
                      );
                    }),
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
                StreamBuilder<bool>(
                    initialData: false,
                    stream: DatabaseService.hasPushNotificationsTurnedOnStream(
                        um.uid),
                    builder: (context, snapshot) {
                      return SwitchListTile(
                          title: Text("Push Benachrichtigungen"),
                          activeColor: _theme.colors.contrast,
                          value: snapshot.data ?? false,
                          onChanged: _togglePushNotifications);
                    }),
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
                ListTile(
                  title: Text("Logout"),
                  trailing: Icon(
                    CupertinoIcons.power,
                    size: 24,
                  ),
                  onTap: () async {
                    await um.logout();

                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (c) => ChooseLoginMethodPage()),
                        (route) => route.isFirst);
                  },
                ),
                SizedBox(
                  height: 10 + MediaQuery.of(context).padding.bottom,
                )
              ]),
        ),
      ),
    );
  }

  Future<bool> showGhostDialog(BuildContext context, bool currentGhost) {
    return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Constants.radius)),
              title: Text("Ghost Modus"),
              content: Text(
                  "Bist du dir sicher, dass du den Ghost Modus ${currentGhost ? "ausschalten" : "anschalten"} willst?\n\n${currentGhost ? "Wenn der Ghost Modus ausgeschaltet ist, kann dich jeder finden!" : "Wenn der Ghost modus eingeschaltet ist, kann dich niemand finden!"}"),
              actions: [
                FlatButton(
                    textColor: ColorTheme.blue,
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: Text("Abbrechen")),
                FlatButton(
                    textColor: ColorTheme.orange,
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: Text(currentGhost ? "Ausschalten" : "Anschalten")),
              ],
            ));
  }

  void launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void _togglePushNotifications(bool val) async {
    final PermissionStatus permission = await Permission.notification.status;

    if (val) {
      if (permission != PermissionStatus.granted) {
        final Map<Permission, PermissionStatus> permissionStatus =
            await [Permission.notification].request();
        PermissionStatus status = permissionStatus[Permission.notification] ??
            PermissionStatus.undetermined;

        if (status == PermissionStatus.granted) await _saveToken();
      } else
        await _saveToken();
    } else {
      await DatabaseService.deleteDeviceToken(um.uid);
    }
  }

  Future<void> _saveToken() async {
    final FirebaseMessaging _fMessaging = FirebaseMessaging();
    String token = await _fMessaging.getToken();
    await DatabaseService.saveDeviceToken(um.uid, token);
  }
}
