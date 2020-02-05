import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/Api.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/MyProjectsPage.dart';
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
                    MaterialPageRoute(builder: (context) => MyProjectsPage()));
              },
            ),
            OutlineButton(
              child: Text("Profil bearbeiten"),
              onPressed: () async {
                await um.logout();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RegisterPage()));
              },
            ),
            OutlineButton(
              child: Text("Datenschutzerklärung"),
              onPressed: () async {
                await um.logout();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RegisterPage()));
              },
            ),
            OutlineButton(
              child: Text("AGB's"),
              onPressed: () async {
                await um.logout();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RegisterPage()));
              },
            ),
            OutlineButton(
              child: Text("Logout"),
              onPressed: () async {
                await um.logout();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RegisterPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
