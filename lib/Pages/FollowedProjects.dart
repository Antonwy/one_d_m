import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/CampaignHeader.dart';
import 'package:one_d_m/Helper/Api.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:provider/provider.dart';

import 'CampaignPage.dart';

class FollowedProjects extends StatelessWidget {

  TextTheme textTheme;
  UserManager um;

  AsyncMemoizer<List<Campaign>> _memoizer = new AsyncMemoizer();

  @override
  Widget build(BuildContext context) {

    textTheme = Theme.of(context).textTheme;
    um = Provider.of<UserManager>(context);

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: Colors.white,
          title: Text("Deine unterstützten Projekte", style: textTheme.title,),
          centerTitle: false,
        ),
        FutureBuilder<List<Campaign>>(
          future: _fetchData(),
          builder: (BuildContext c, AsyncSnapshot<List<Campaign>> snapshot) {
            if(snapshot.hasData) {
              return SliverList(delegate: SliverChildListDelegate(_buildChildren(context, snapshot.data)),);
            }
            return SliverFillRemaining(child: Center(child: CircularProgressIndicator(),),);
          },
        ),
      ],
    );
  }

  Future<List<Campaign>> _fetchData() {
    return _memoizer.runOnce(() async {
      return await Api.getSubscribedCampaigns(um.user.id);
    });
  }

  List<Widget> _buildChildren(BuildContext context, List<Campaign> data) {
    List<Widget> list = [];

    for (Campaign c in data) {
      list.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
        child: Column(
          children: <Widget>[
            Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CampaignPage(c)));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CampaignHeader(c),
                  ),
                )),
          ],
        ),
      ));
    }

    list.add(SizedBox(
      height: 100,
    ));

    return list;
  }

}
