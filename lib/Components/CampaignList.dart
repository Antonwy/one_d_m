import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/Components/NativeAd.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/Constants.dart';

import 'CampaignHeader.dart';

class CampaignList extends StatefulWidget {
  List<Campaign> campaigns;

  CampaignList({Key key, this.campaigns}) : super(key: key);

  @override
  _CampaignListState createState() => _CampaignListState();
}

class _CampaignListState extends State<CampaignList> {
  @override
  Widget build(BuildContext context) {
    if (widget.campaigns.isEmpty) {
      return SliverFillRemaining(
        child: Center(
            child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              SvgPicture.asset(
                "assets/images/no-news.svg",
                height: MediaQuery.of(context).size.height * .25,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Keine Projekte vorhanden",
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ],
          ),
        )),
      );
    }

    return SliverList(
        delegate: SliverChildListDelegate(_buildChildren(widget.campaigns)));
  }

  List<Widget> _buildChildren(List<Campaign> campaigns) {
    List<Widget> list = [];
    int adRate = Constants.AD_CAMPAIGNS_RATE;
    int rateCount = 0;

    for (Campaign c in campaigns) {
      rateCount++;

      list.add(CampaignHeader(c));

      if (rateCount >= adRate) {
        list.add(ExploreNativeAd());
        rateCount = 0;
      }
    }

    list.add(SizedBox(
      height: 100,
    ));

    return list;
  }
}
