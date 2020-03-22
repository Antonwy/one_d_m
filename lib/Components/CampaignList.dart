import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/Campaign.dart';

import 'CampaignHeader.dart';

class CampaignList extends StatefulWidget {
  Future<List<Campaign>> campaignsFuture;
  ImageProvider emptyImage;
  String emptyMessage;

  CampaignList(
      {Key key, this.campaignsFuture, this.emptyImage, this.emptyMessage})
      : super(key: key);

  @override
  _CampaignListState createState() => _CampaignListState();
}

class _CampaignListState extends State<CampaignList> {
  Future<List<Campaign>> _campaignsFuture;

  @override
  void initState() {
    _campaignsFuture = widget.campaignsFuture;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Campaign>>(
      future: _campaignsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.isEmpty)
            return SliverFillRemaining(
              child: Center(
                  child: Column(
                children: <Widget>[
                  Image(
                    image: widget.emptyImage,
                  ),
                  Text(
                    widget.emptyMessage,
                    style: Theme.of(context).textTheme.body2,
                  ),
                ],
              )),
            );

          return ListView(children: _buildChildren(snapshot.data));
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
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
