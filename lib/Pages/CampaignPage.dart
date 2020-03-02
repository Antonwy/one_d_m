import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/API/Api.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/User.dart';

class CampaignPage extends StatefulWidget {
  Campaign campaign;

  CampaignPage(this.campaign);

  @override
  _CampaignPageState createState() => _CampaignPageState();
}

class _CampaignPageState extends State<CampaignPage> {
  ThemeData theme;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        textTheme: theme.textTheme,
        iconTheme: theme.iconTheme,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Hero(
                    tag: "${widget.campaign.name}Img",
                    child: Center(
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(widget.campaign.imgUrl),
                        radius: 70,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Text(
                      widget.campaign.name,
                      style: theme.textTheme.title,
                    ),
                  ),
                  Center(
                    child: FutureBuilder<User>(
                      future: Api.getUserWithId(widget.campaign.authorId),
                      builder: (context, snapshot) {
                        if(snapshot.hasData) return Text(
                          "by ${snapshot.data?.firstname} ${snapshot.data?.lastname}",
                          style: theme.textTheme.subtitle
                              .copyWith(color: Colors.black54),
                        );
                        return Container();
                      }
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    campaignText,
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                  ),
                  SizedBox(
                    height: 150,
                  )
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 5),
                      child: Container(
                        height: 55,
                        child: Material(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                          clipBehavior: Clip.antiAlias,
                          elevation: 10,
                          child: InkWell(
                            onTap: () {},
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
                      padding: const EdgeInsets.only(right: 20.0, left: 5),
                      child: Container(
                        height: 55,
                        child: Material(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                          clipBehavior: Clip.antiAlias,
                          elevation: 10,
                          child: InkWell(
                            onTap: () async {
                              if(!widget.campaign.subscribed) await Api.subscribe(widget.campaign.id);
                              else await Api.deleteSubscription(widget.campaign.id);
                              setState(() {
                                widget.campaign.toggleSubscribed();
                              });
                            },
                            child: Center(
                              child: Text(
                                widget.campaign.subscribed ? "Nicht mehr unterstützen" : "Unterstützen",
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
      ),
    );
  }
}

String campaignText =
    "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.";
