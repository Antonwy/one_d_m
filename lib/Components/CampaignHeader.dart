import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Pages/CampaignPage.dart';

class CampaignHeader extends StatelessWidget {
  Campaign campaign;

  TextTheme textTheme;

  CampaignHeader(this.campaign);

  @override
  Widget build(BuildContext context) {
    textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
      child: Container(
        height: 230,
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CampaignPage(campaign)));
              },
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      CachedNetworkImage(
                          width: 150,
                          height: 150,
                          placeholder: (context, url) =>
                              Center(child: CircularProgressIndicator()),
                          imageUrl: campaign.imgUrl,
                          fit: BoxFit.cover),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                campaign.name,
                                style: textTheme.title.copyWith(fontSize: 25),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Für die Rettung des Planeten!",
                                style: textTheme.subtitle
                                    .copyWith(color: Colors.black54),
                                    textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 1,
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text(
                            "${campaign.amount}€",
                            style: textTheme.title,
                          ),
                          Text(
                            "Spenden",
                            style: textTheme.subtitle
                                .copyWith(color: Colors.black54),
                          ),
                        ],
                      ),
                      SizedBox(width: 10),
                      Column(
                        children: <Widget>[
                          Text(
                            "+126",
                            style: textTheme.title,
                          ),
                          Text(
                            "Mitglieder",
                            style: textTheme.subtitle
                                .copyWith(color: Colors.black54),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              )),
        ),
      ),
    );
  }
}
