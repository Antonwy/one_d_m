import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Components/CustomOpenContainer.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/ChooseLoginMethodPage.dart';
import 'package:one_d_m/Pages/EditProfile.dart';
import 'package:one_d_m/Pages/FaqPage.dart';
import 'package:one_d_m/Pages/MyCampaignsPage.dart';
import 'package:one_d_m/Pages/UserPage.dart';
import 'package:one_d_m/Pages/UsersDonationsPage.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsDialog extends StatelessWidget {
  UserManager um;
  TextTheme _textTheme;

  @override
  Widget build(BuildContext context) {
    um = Provider.of<UserManager>(context);
    _textTheme = Theme.of(context).accentTextTheme;
    return Material(
      color: ColorTheme.navBar,
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: DefaultTextStyle(
          style: TextStyle(color: ColorTheme.blue),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CustomOpenContainer(
                openBuilder: (context, close, controller) =>
                    UserPage(um.user, scrollController: controller),
                closedElevation: 0,
                closedColor: ColorTheme.whiteBlue,
                closedBuilder: (context, open) => Material(
                  borderRadius: BorderRadius.circular(5),
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
                                child: Avatar(
                                    um.user?.thumbnailUrl ?? um.user?.imgUrl),
                                width: 50,
                                height: 50,
                              ),
                            ),
                            color: ThemeManager.of(context).theme.contrast,
                            shape: CircleBorder(),
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
              SizedBox(height: 10),
              Container(
                height: 50,
                padding: const EdgeInsets.only(left: 12),
                child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: ThemeHolder.themes.length,
                    separatorBuilder: (context, index) => SizedBox(
                          width: 10,
                        ),
                    itemBuilder: (context, index) {
                      BaseTheme bTheme = ThemeHolder.themes[index];
                      return Material(
                        clipBehavior: Clip.antiAlias,
                        shape: CircleBorder(),
                        child: InkWell(
                          onTap: () async {
                            ThemeManager.of(context, listen: false).theme =
                                bTheme;
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setInt(Constants.THEME_KEY, index);
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            color: bTheme.dark,
                            child: Column(
                              children: [
                                Container(
                                  width: 50,
                                  height: 25,
                                  color: bTheme.dark,
                                ),
                                Container(
                                  width: 50,
                                  height: 25,
                                  color: bTheme.contrast,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              ),
              SizedBox(height: 10),
              StreamBuilder<bool>(
                  stream: DatabaseService.isGhost(um.uid),
                  initialData: false,
                  builder: (context, snapshot) {
                    bool isGhost = snapshot.data;
                    return ListTile(
                      title: Text("Ghost Modus"),
                      subtitle: Text(
                          "${isGhost ? "Niemand" : "Jeder"} kann dein Profil sehen"),
                      trailing: Icon(
                        isGhost ? Icons.visibility_off : Icons.visibility,
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
                title: Text("Meine Spenden"),
                subtitle: Text("Alle deine Spenden aufgelistet."),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UsersDonationsPage(um.user)));
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
                  Icons.power_settings_new,
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
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> showGhostDialog(BuildContext context, bool currentGhost) {
    return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
}
