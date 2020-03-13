import 'package:flutter/material.dart';
import 'package:one_d_m/Components/CampaignHeader.dart';
import 'package:one_d_m/Helper/API/ApiResult.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
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
  UserManager um;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    um = Provider.of<UserManager>(context);
    GlobalKey _createNowKey = GlobalKey();

    return Scaffold(
      appBar: AppBar(
        textTheme: theme.textTheme,
        iconTheme: theme.iconTheme,
        title: Text("Meine Projekte"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<List<Campaign>>(
          stream: DatabaseService(um.uid).getMyCampaignsStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ListView(
                      children: <Widget>[
                        Text("Du hast noch kein Projekt erstellt!"),
                        SizedBox(
                          height: 10,
                        ),
                        RaisedButton(
                          key: _createNowKey,
                          onPressed: () {
                            Navigator.push(
                                context,
                                RectRevealRoute(
                                    page: CreateCampaignPage(),
                                    startColor: theme.primaryColor,
                                    color: theme.primaryColor,
                                    startRadius: 2,
                                    duration: Duration(milliseconds: 500),
                                    offset: Helper.getCenteredPositionFromKey(
                                        _createNowKey),
                                    startSize:
                                        Helper.getSizeFromKey(_createNowKey)));
                          },
                          child: Text(
                            "Jetzt erstellen!",
                            style: TextStyle(color: Colors.white),
                          ),
                          color: theme.primaryColor,
                        )
                      ],
                    ),
                  ),
                );
              }
              return ListView(
                children: _getMyProjects(snapshot.data),
              );
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }

  List<Widget> _getMyProjects(List<Campaign> campaigns) {
    List<Widget> list = [];

    for (Campaign c in campaigns) {
      list.add(CampaignHeader(c));
    }

    return list;
  }
}
