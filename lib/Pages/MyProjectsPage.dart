import 'package:flutter/material.dart';
import 'package:one_d_m/Components/CampaignItem.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/PlaceholderData.dart';

class MyProjectsPage extends StatelessWidget {
  ThemeData theme;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        textTheme: theme.textTheme,
        iconTheme: theme.iconTheme,
        title: Text("Meine Projekte"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        children: _getMyProjects(),
      ),
    );
  }

  List<Widget> _getMyProjects() {
    List<Widget> list = [];

    for (Campaign c in PlaceholderData.campaigns) {
      list.add(CampaignItem(c));
    }

    return list;
  }

}
