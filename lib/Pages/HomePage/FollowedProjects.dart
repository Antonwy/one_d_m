import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/CampaignHeader.dart';
import 'package:one_d_m/Helper/API/Api.dart';
import 'package:one_d_m/Helper/API/ApiResult.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:provider/provider.dart';

import '../CampaignPage.dart';

class FollowedProjects extends StatefulWidget {

  @override
  _FollowedProjectsState createState() => _FollowedProjectsState();
}

class _FollowedProjectsState extends State<FollowedProjects> {
  TextTheme textTheme;

  UserManager um;

  Future<ApiResult> _future;
  
  @override
  void initState() {
    _future = Api.getSubscribedCampaigns();
    super.initState();
  }

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
        FutureBuilder<ApiResult>(
          future: _future,
          builder: (BuildContext c, AsyncSnapshot<ApiResult> snapshot) {
            if(snapshot.hasData) {
              return SliverList(delegate: SliverChildListDelegate(_buildChildren(context, snapshot.data.getData())),);
            }
            return SliverFillRemaining(child: Center(child: CircularProgressIndicator(),),);
          },
        ),
      ],
    );
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
