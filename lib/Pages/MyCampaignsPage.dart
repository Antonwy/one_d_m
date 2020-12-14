import 'package:flutter/material.dart';
import 'package:one_d_m/Components/CampaignHeader.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MyCampaignsPage extends StatefulWidget {
  @override
  _MyCampaignsPageState createState() => _MyCampaignsPageState();
}

class _MyCampaignsPageState extends State<MyCampaignsPage> {
  ThemeData theme;
  List<Campaign> campaigns;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    GlobalKey _createNowKey = GlobalKey();

    return Scaffold(
      appBar: AppBar(
        textTheme: theme.textTheme,
        iconTheme: theme.iconTheme,
        title: Text("Meine Projekte"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<UserManager>(builder: (context, um, child) {
        return FutureBuilder<List<Campaign>>(
          future: DatabaseService.getMyCampaigns(um.uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(ColorTheme.blue)));
            campaigns = snapshot.data;
            if (campaigns.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListView(
                    children: <Widget>[
                      Text("Du hast noch kein Projekt erstellt!"),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                          "Projekte können nur von Administratoren erstellt werden!\nKontaktiere uns wenn du ein Projekt hast, was hier angezeigt werden soll!"),
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: RaisedButton(
                            color: ColorTheme.blue,
                            textColor: ColorTheme.whiteBlue,
                            onPressed: () {
                              final Uri _emailLaunchUri = Uri(
                                  scheme: 'mailto',
                                  path: 'anton@one-dollar-movement.com',
                                  queryParameters: {
                                    'subject': 'Projekt Vorschlag ODM'
                                  });
                              launch(_emailLaunchUri.toString());
                            },
                            child: Text("Email schicken")),
                      )
                    ],
                  ),
                ),
              );
            }
            return ListView(
              children: _getMyProjects(),
            );
          },
        );
      }),
    );
  }

  List<Widget> _getMyProjects() {
    List<Widget> list = [];

    for (Campaign c in campaigns) {
      list.add(CampaignHeader(campaign: c,));
    }

    return list;
  }
}
