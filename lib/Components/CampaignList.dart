import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/Helper/Campaign.dart';

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
            child: Column(
          children: <Widget>[
            SvgPicture.asset("assets/images/no-news.svg"),
            Text(
              "Keine Projekte vorhanden",
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ],
        )),
      );
    }

    return SliverList(
        delegate: SliverChildListDelegate(_buildChildren(widget.campaigns)));
  }

  List<Widget> _buildChildren(List<Campaign> campaigns) {
    List<Widget> list = [];

    for (Campaign c in campaigns) {
      list.add(CampaignHeader(c));
    }

    list.add(SizedBox(
      height: 100,
    ));

    return list;
  }
}
