import 'package:flutter/material.dart';
import 'package:one_d_m/Components/CampaignHeader.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/CampaignsManager.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/RectRevealRoute.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/CreateCampaignPage.dart';
import 'package:provider/provider.dart';

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
      body: Consumer2<UserManager, CampaignsManager>(
          builder: (context, um, cm, child) {
        campaigns = cm.getCampaingsFrom(um.uid);

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
                ],
              ),
            ),
          );
        }
        return ListView(
          children: _getMyProjects(),
        );
      }),
    );
  }

  List<Widget> _getMyProjects() {
    List<Widget> list = [];

    for (Campaign c in campaigns) {
      list.add(CampaignHeader(c));
    }

    return list;
  }
}
