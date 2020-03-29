import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/CampaignPageRoute.dart';
import 'package:one_d_m/Components/UserPageRoute.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/SearchResult.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Pages/UserPage.dart';

import 'Avatar.dart';

class SearchResultsList extends StatelessWidget {
  String query;
  BuildContext _context;

  SearchResultsList(this.query);

  @override
  Widget build(BuildContext context) {
    _context = context;
    return FutureBuilder<SearchResult>(
        future: DatabaseService().getSearchResultFromQuery(query),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            SearchResult res = snapshot.data;
            return ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                res.campaigns.isEmpty
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.only(left: 20, bottom: 10),
                        child: Text("Projekte"),
                      ),
                ..._buildCampaigns(res.campaigns),
                res.users.isEmpty
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.only(
                            left: 20, bottom: 10, top: 10),
                        child: Text("Nutzer"),
                      ),
                ..._buildUsers(res.users),
                SizedBox(height: 50)
              ],
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  _buildCampaigns(List<Campaign> campaigns) {
    List<Widget> res = [];

    campaigns.forEach((c) {
      res.add(_buildCampaign(c));
    });

    return res;
  }

  _buildCampaign(Campaign campaign) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: ListTile(
          onTap: () {
            Navigator.push(_context, CampaignPageRoute(campaign));
          },
          leading: Avatar(
            campaign.imgUrl,
          ),
          title: Text(campaign.name),
        ),
      ),
    );
  }

  _buildUsers(List<User> users) {
    List<Widget> res = [];
    users.forEach((u) {
      res.add(_buildUser(u));
    });

    return res;
  }

  _buildUser(User user) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: ListTile(
          onTap: () {
            Navigator.push(_context, UserPageRoute(user));
          },
          leading: Avatar(user.imgUrl),
          title: Text("${user.firstname} ${user.lastname}"),
        ),
      ),
    );
  }
}
