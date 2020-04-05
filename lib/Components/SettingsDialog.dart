import 'package:flutter/material.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Components/UserButton.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/EditProfile.dart';
import 'package:one_d_m/Pages/MyCampaignsPage.dart';
import 'package:one_d_m/Pages/RegisterPage.dart';
import 'package:provider/provider.dart';

class SettingsDialog extends StatelessWidget {
  UserManager um;

  @override
  Widget build(BuildContext context) {
    um = Provider.of<UserManager>(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            UserButton(
              um.uid,
              user: um.user,
            ),
            SizedBox(height: 10),
            ListTile(
              title: Text("Meine Projekte"),
              subtitle: Text("Projekte die du erstellt hast."),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 18,
              ),
              onTap: () async {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyCampaignsPage()));
              },
            ),
            ListTile(
              title: Text("Profil Einstellungen"),
              subtitle: Text("${um.user.firstname} ${um.user.lastname}"),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 18,
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
              ),
              onTap: () async {
                await um.logout();
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (c) => RegisterPage()));
              },
            ),
            SizedBox(height: 20),
            Text("Illustrations by Ouch.pics: https://icons8.com"),
            SizedBox(
              height: 10 + MediaQuery.of(context).padding.bottom,
            )
          ],
        ),
      ),
    );
  }
}
