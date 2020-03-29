import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/CampaignPageRoute.dart';
import 'package:one_d_m/Helper/Campaign.dart';

class CampaignHeader extends StatelessWidget {
  Campaign campaign;

  TextTheme textTheme;

  BuildContext context;

  bool isFollowed = false, expanded;

  Function(bool) onExpand;

  CampaignHeader(this.campaign, {this.onExpand, this.expanded = false});

  GlobalKey _cardKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    this.context = context;
    textTheme = Theme.of(context).textTheme;

    return _secondLayout();
  }

  Widget _secondLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
      child: Column(
        children: <Widget>[
          Material(
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () {
                Navigator.push(context, CampaignPageRoute(campaign));
              },
              child: Image(
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(
                  campaign.imgUrl,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Card(
            key: _cardKey,
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.all(0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ExpansionTile(
              //onExpansionChanged: onExpand,
              title: Text(
                campaign.name,
                style: textTheme.title,
              ),
              subtitle: campaign.shortDescription == null
                  ? null
                  : Text(campaign.shortDescription),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
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
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
