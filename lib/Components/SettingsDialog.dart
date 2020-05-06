import 'package:flutter/material.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/EditProfile.dart';
import 'package:one_d_m/Pages/FaqPage.dart';
import 'package:one_d_m/Pages/MyCampaignsPage.dart';
import 'package:one_d_m/Pages/RegisterPage.dart';
import 'package:provider/provider.dart';
import 'UserPageRoute.dart';

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
        child: Theme(
          data: Theme.of(context).copyWith(
            textTheme: _textTheme,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Material(
                borderRadius: BorderRadius.circular(5),
                clipBehavior: Clip.antiAlias,
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(context, UserPageRoute(um.user));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Material(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Container(
                              child: Avatar(
                                  um.user?.thumbnailUrl ?? um.user.imgUrl),
                              width: 50,
                              height: 50,
                            ),
                          ),
                          color: Colors.white,
                          shape: CircleBorder(),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "${um.user.firstname} ${um.user.lastname}",
                          style: _textTheme.title,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ListTile(
                title: Text("FAQ"),
                subtitle: Text("Häufig gestellte Fragen."),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.white,
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => FaqPage()));
                },
              ),
              ListTile(
                title: Text("Meine Projekte"),
                subtitle: Text("Projekte die du erstellt hast."),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.white,
                ),
                onTap: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyCampaignsPage()));
                },
              ),
              ListTile(
                title: Text("Profil Einstellungen"),
                subtitle: Text("${um.user.firstname} ${um.user.lastname}"),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.white,
                ),
                onTap: () async {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => EditProfile()));
                },
              ),
              ListTile(
                title: Text("Datenschutzerklärung"),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.white,
                ),
                onTap: () async {
                  showLicensePage(context: context);
                },
              ),
              ListTile(
                title: Text("AGB's"),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.white,
                ),
                onTap: () async {
                  showAboutDialog(
                      context: context,
                      applicationName: "One Dollar Movement",
                      applicationVersion: "1.0.4");
                },
              ),
              ListTile(
                title: Text("Logout"),
                trailing: Icon(
                  Icons.power_settings_new,
                  size: 24,
                  color: Colors.white,
                ),
                onTap: () async {
                  await um.logout();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (c) => RegisterPage()));
                },
              ),
              SizedBox(height: 20),
              Text(
                "Illustrations by Ouch.pics: https://icons8.com",
                style: _textTheme.body1,
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
}
