import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Pages/CampaignPage.dart';

class CampaignHeader extends StatelessWidget {
  Campaign campaign;

  TextTheme textTheme;

  BuildContext context;

  bool isFollowed = false;

  CampaignHeader(this.campaign, [this.isFollowed = false]);

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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) =>
                            CampaignPage(campaign, isFollowed)));

                /*Navigator.push(
                    context,
                    CampaignRevealRoute(
                        page: CampaignPage(campaign), widgetKey: _cardKey));*/
              },
              child: Hero(
                tag: "image-${campaign.imgUrl}${isFollowed ? "followed" : ""}",
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
          ),
          Card(
            key: _cardKey,
            clipBehavior: Clip.antiAlias,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ExpansionTile(
              title: Text(
                campaign.name,
                style: textTheme.title,
              ),
              subtitle: Text("To make the world a better place!"),
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
