import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/EditProfile.dart';
import 'package:one_d_m/Pages/MyCampaignsPage.dart';
import 'package:one_d_m/Pages/RegisterPage.dart';
import 'package:provider/provider.dart';

class SettingsDialog extends StatelessWidget {
  Size _displaySize;
  UserManager um;

  @override
  Widget build(BuildContext context) {
    _displaySize = MediaQuery.of(context).size;
    um = Provider.of<UserManager>(context);
    return Container(
      height: _displaySize.height * .6,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Einstellungen",
                style: Theme.of(context).textTheme.title,
              ),
              SizedBox(height: 20),
              OutlineButton(
                child: Text("Meine Projekte"),
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyCampaignsPage()));
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
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (c) => RegisterPage()));
                },
              ),
              SizedBox(height: 20),
              Text("Illustrations by Ouch.pics: https://icons8.com")
            ],
          ),
        ),
      ),
    );
  }
}
