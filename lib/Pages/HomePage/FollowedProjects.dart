import 'package:flutter/material.dart';
import 'package:one_d_m/Components/CampaignHeader.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:provider/provider.dart';

import '../CampaignPage.dart';

class FollowedProjects extends StatefulWidget {
  Function goToExplore;

  FollowedProjects(this.goToExplore);

  @override
  _FollowedProjectsState createState() => _FollowedProjectsState();
}

class _FollowedProjectsState extends State<FollowedProjects> {
  TextTheme textTheme;

  UserManager um;

  @override
  Widget build(BuildContext context) {
    textTheme = Theme.of(context).textTheme;
    um = Provider.of<UserManager>(context);

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: Colors.white,
          title: Text(
            "Deine unterstützten Projekte",
            style: textTheme.title,
          ),
          centerTitle: false,
        ),
        StreamBuilder<List<Campaign>>(
            stream: DatabaseService(um.uid).getSubscribedCampaignsStream(),
            builder: (BuildContext c, snapshot) {
              if (!snapshot.hasData) {
                return SliverFillRemaining(
                    child: Center(
                  child: CircularProgressIndicator(),
                ));
              }

              if (snapshot.data.isEmpty) {
                return SliverFillRemaining(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 50),
                      Image.asset("assets/images/clip-no-comments.png"),
                      Text(
                        "Du hast noch keine unterstützten Projekte!",
                        style: textTheme.body2,
                      ),
                      SizedBox(height: 10),
                      RaisedButton(
                        onPressed: widget.goToExplore,
                        child: Text(
                          "Entdecke Projekte!",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Theme.of(context).primaryColor,
                      )
                    ],
                  ),
                );
              }

              return SliverList(
                  delegate: SliverChildListDelegate(
                      _buildChildren(context, snapshot.data)));
            }),
      ],
    );
  }

  List<Widget> _buildChildren(BuildContext context, List<Campaign> data) {
    List<Widget> list = [];

    for (Campaign c in data) {
      list.add(CampaignHeader(c));
    }

    list.add(SizedBox(
      height: 100,
    ));

    return list;
  }

}
