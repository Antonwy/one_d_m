import 'package:flutter/material.dart';
import 'package:one_d_m/Components/CampaignHeader.dart';
import 'package:one_d_m/Components/CampaignList.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:provider/provider.dart';

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

    return NestedScrollView(
      headerSliverBuilder: (context, b) => <Widget>[
        SliverAppBar(
          backgroundColor: Colors.white,
          title: Text(
            "Deine unterstützten Projekte",
            style: textTheme.title,
          ),
          centerTitle: false,
        ),
      ],
      body: CampaignList(
        campaignsFuture: DatabaseService(um.uid).getSubscribedCampaigns(),
        emptyImage: AssetImage("assets/images/clip-no-comments.png"),
        emptyMessage: "Du hast noch keine unterstützten Projekte!",
      ),
    );
  }
}
