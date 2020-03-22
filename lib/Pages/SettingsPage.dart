import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/EditProfile.dart';
import 'package:one_d_m/Pages/MyCampaignsPage.dart';
import 'package:one_d_m/Pages/RegisterPage.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  ThemeData theme;

  UserManager um;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    um = Provider.of<UserManager>(context);

    return Scaffold(
      appBar: AppBar(
        textTheme: theme.textTheme,
        iconTheme: theme.iconTheme,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Einstellungen",
        ),
      ),
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            OutlineButton(
              child: Text("Meine Projekte"),
              onPressed: () async {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyCampaignsPage()));
              },
            ),
            OutlineButton(
              child: Text("Profil bearbeiten"),
              onPressed: () async {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => EditProfile()));
              },
            ),
            OutlineButton(
              child: Text("Datenschutzerklärung"),
              onPressed: () async {
                showLicensePage(context: context);
              },
            ),
            OutlineButton(
              child: Text("AGB's"),
              onPressed: () async {
                showAboutDialog(
                    context: context,
                    applicationName: "One Dollar Movement",
                    applicationVersion: "1.0.4");
              },
            ),
            OutlineButton(
              child: Text("Logout"),
              onPressed: () async {
                await um.logout();
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (c) => RegisterPage()));
              },
            ),
            SizedBox(height: 20),
            Text("Illustrations by Ouch.pics: https://icons8.com")
          ],
        ),
      ),
    );
  }
}
