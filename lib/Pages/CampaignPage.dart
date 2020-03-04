import 'dart:async';

import 'package:flutter/material.dart';
import 'package:one_d_m/Components/AnimatedFutureBuilder.dart';
import 'package:one_d_m/Components/NewsBody.dart';
import 'package:one_d_m/Components/UserButton.dart';
import 'package:one_d_m/Helper/API/Api.dart';
import 'package:one_d_m/Helper/API/ApiResult.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Pages/BuyCoinsPage.dart';

import 'UserPage.dart';

class CampaignPage extends StatefulWidget {
  Campaign campaign;
  int campaignId;

  CampaignPage({this.campaign, this.campaignId});

  @override
  _CampaignPageState createState() => _CampaignPageState();
}

class _CampaignPageState extends State<CampaignPage> {
  ThemeData theme;

  Future<ApiResult<Campaign>> _future;

  @override
  void initState() {
    super.initState();
    if (widget.campaign == null) {
      _future = Api.getCampaignFromId(widget.campaignId);
    } else {
      _future = Future.value(ApiResult(message: "Success", data: widget.campaign));
    }
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: FutureBuilder<ApiResult<Campaign>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.hasData) return Text(snapshot.data.getData().name);
              return Container();
            }),
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<ApiResult<Campaign>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Campaign campaign = snapshot.data.getData();
              return Stack(
                children: <Widget>[
                  SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 20),
                          Center(
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(campaign.imgUrl),
                              radius: 70,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Center(
                            child: Text(
                              campaign.name,
                              style: theme.textTheme.title,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                _detailsRow(
                                    icon: Icons.location_city, text: "Koeln"),
                                _detailsRow(
                                    icon: Icons.monetization_on,
                                    text: "25643 Coins"),
                                _detailsRow(
                                    icon: Icons.access_time, text: "Unendlich"),
                                _detailsRow(
                                    icon: Icons.people,
                                    text: "1400 Mitglieder"),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            campaignText,
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 18),
                          ),
                          SizedBox(height: 20),
                          UserButton(campaign.authorId),
                          FutureBuilder<ApiResult<List<News>>>(
                              future: Api.getNewsFromCampaignId(campaign.id),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return _generateNews(snapshot.data.getData());
                                }
                                return Container();
                              }),
                          SizedBox(
                            height: 150,
                          )
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SafeArea(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 20.0, right: 5),
                              child: Container(
                                height: 55,
                                child: Material(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(8),
                                  clipBehavior: Clip.antiAlias,
                                  elevation: 10,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (c) => BuyCoinsPage()));
                                    },
                                    child: Center(
                                      child: Text(
                                        "Spenden",
                                        style: theme.accentTextTheme.title,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 20.0, left: 5),
                              child: Container(
                                height: 55,
                                child: Material(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(8),
                                  clipBehavior: Clip.antiAlias,
                                  elevation: 10,
                                  child: InkWell(
                                    onTap: () async {
                                      if (!campaign.subscribed)
                                        await Api.subscribe(campaign.id);
                                      else
                                        await Api.deleteSubscription(
                                            campaign.id);
                                      setState(() {
                                        campaign.toggleSubscribed();
                                      });
                                    },
                                    child: Center(
                                      child: Text(
                                        campaign.subscribed
                                            ? "Nicht mehr unterstützen"
                                            : "Unterstützen",
                                        style: theme.accentTextTheme.title,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              );
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }

  Widget _generateNews(List<News> news) {
    List<Widget> widgets = [];

    widgets.add(Align(alignment: Alignment.centerLeft, child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
      child: Text("News: ", style: theme.textTheme.title,),
    )));

    for (News n in news) {
      widgets.add(NewsBody(n));
    }

    return Column(
      children: widgets,
    );
  }

  Widget _detailsRow({IconData icon, String text}) => Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 35),
          SizedBox(width: 10),
          Text(text),
        ],
      );
}

String campaignText =
    "Die Tropenwaldstiftung OroVerde (=span. 'Grünes Gold') setzt sich für den Erhalt der tropischen Regenwälder ein. Dabei gehen Regenwaldschutz und Entwicklungszusammenarbeit Hand in Hand, denn nur mit den Menschen vor Ort sind Regenwald-Schutzprojekte langfristig erfolgreich und lässt sich Regenwald schützen. Zugleich setzt OroVerde auf Bildungsprojekte und Verbrauchertipps in Deutschland, denn Regenwaldschutz fängt mit dem Einkaufswagen an. Empfehlungen für Politik, Gesetzgebung und Unternehmen runden die Arbeitsfelder zur Rettung der Tropenwälder ab. Seien auch Sie dabei und ermöglichen Sie Regenwaldschutz mit Ihrer Spende!";
