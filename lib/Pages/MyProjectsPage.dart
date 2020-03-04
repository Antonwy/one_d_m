import 'package:flutter/material.dart';
import 'package:one_d_m/Components/CampaignHeader.dart';
import 'package:one_d_m/Helper/API/Api.dart';
import 'package:one_d_m/Helper/API/ApiResult.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/RectRevealRoute.dart';
import 'package:one_d_m/Pages/CreateCampaignPage.dart';

class MyProjectsPage extends StatefulWidget {
  @override
  _MyProjectsPageState createState() => _MyProjectsPageState();
}

class _MyProjectsPageState extends State<MyProjectsPage> {
  ThemeData theme;
  Future _future;

  @override
  void initState() {
    super.initState();
    _future = Api.getMyCampaigns();
  }

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
      body: RefreshIndicator(
        onRefresh: () {
          Future res = Api.getMyCampaigns();
          setState(() {
            _future = res;
          });
          return res;
        },
        child: FutureBuilder<ApiResult<List<Campaign>>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.getData().isEmpty) {
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
                                      startSize: Helper.getSizeFromKey(
                                          _createNowKey)));
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
                  children: _getMyProjects(snapshot.data.getData()),
                );
              }
              return Center(child: CircularProgressIndicator());
            }),
      ),
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
