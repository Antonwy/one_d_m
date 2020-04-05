import 'package:flutter/material.dart';
import 'package:one_d_m/Components/CampaignList.dart';
import 'package:one_d_m/Helper/CampaignsManager.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:provider/provider.dart';

class FollowedProjects extends StatefulWidget {
  Function goToExplore;

  FollowedProjects(this.goToExplore);

  @override
  _FollowedProjectsState createState() => _FollowedProjectsState();
}

class _FollowedProjectsState extends State<FollowedProjects>
    with AutomaticKeepAliveClientMixin {
  TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    textTheme = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            "Deine unterstützten Projekte",
            style: textTheme.title,
          ),
          centerTitle: false,
        ),
        Consumer2<CampaignsManager, UserManager>(
          builder: (context, cm, um, child) => CampaignList(
            campaigns: cm.getSubscribedCampaigns(um.user),
            emptyImage: AssetImage("assets/images/clip-no-comments.png"),
            emptyMessage: "Du hast noch keine unterstützten Projekte!",
          ),
        )
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
