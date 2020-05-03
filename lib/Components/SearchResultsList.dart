import 'package:flutter/material.dart';
import 'package:one_d_m/Components/UserButton.dart';
import 'package:one_d_m/Components/UserPageRoute.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/CampaignsManager.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:provider/provider.dart';
import 'CampaignButton.dart';

class SearchResultsList extends StatelessWidget {
  String query;

  SearchResultsList(this.query);

  @override
  Widget build(BuildContext context) {
    return Consumer<CampaignsManager>(builder: (context, cm, child) {
      return FutureBuilder<List<User>>(
          future: DatabaseService().getUsersFromQuery(query),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Campaign> resCampaigns = cm.queryCampaigns(query);
              List<User> resUsers = snapshot.data;
              return SliverList(
                  delegate: SliverChildListDelegate(
                [
                  SizedBox(
                    height: 10,
                  ),
                  resUsers.isEmpty
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.only(
                              left: 20, bottom: 10, top: 10),
                          child: Text(
                            "Nutzer",
                            style: Theme.of(context).textTheme.title,
                          ),
                        ),
                  ..._buildUsers(resUsers),
                  SizedBox(
                    height: 10,
                  ),
                  resCampaigns.isEmpty
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.only(left: 20, bottom: 10),
                          child: Text(
                            "Projekte",
                            style: Theme.of(context).textTheme.title,
                          ),
                        ),
                  ..._buildCampaigns(resCampaigns),
                  SizedBox(height: 50)
                ],
              ));
            }
            return SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          });
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
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: CampaignButton(
        campaign.id,
        textStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
        campaign: campaign,
        elevation: 1,
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
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: UserButton(
        user.id,
        user: user,
        textStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
      ),
    );
  }
}
