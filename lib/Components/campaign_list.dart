import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/models/campaign_models/base_campaign.dart';
import 'package:one_d_m/models/campaign_models/campaign.dart';

import 'campaign_header.dart';

class CampaignList extends StatefulWidget {
  List<BaseCampaign> campaigns;

  CampaignList({Key key, this.campaigns}) : super(key: key);

  @override
  _CampaignListState createState() => _CampaignListState();
}

class _CampaignListState extends State<CampaignList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

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
        delegate: SliverChildListDelegate(_buildChildren(widget.campaigns),
            addAutomaticKeepAlives: false, addRepaintBoundaries: false));
  }

  List<Widget> _buildChildren(List<BaseCampaign> campaigns) {
    List<Widget> list = [];

    for (BaseCampaign c in campaigns) {
      list.add(CampaignHeader(
        campaign: c,
      ));
    }

    list.add(SizedBox(
      height: 100,
    ));

    return list;
  }
}
