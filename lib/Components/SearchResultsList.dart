import 'package:flutter/material.dart';
import 'package:one_d_m/Components/OrganisationButton.dart';
import 'package:one_d_m/Components/UserButton.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Organisation.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:provider/provider.dart';
import 'CampaignButton.dart';
import 'SessionButton.dart';

class SearchResultsList extends StatelessWidget {
  String query;

  SearchResultsList(this.query);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Campaign>>(
        future: DatabaseService.getCampaignFromQuery(query),
        builder: (context, cSnapshot) {
          return FutureBuilder<List<User>>(
              future: DatabaseService.getUsersFromQuery(query),
              builder: (context, uSnapshot) {
                return FutureBuilder<List<BaseSession>>(
                  future: DatabaseService.getSessionsFromQuery(query),
                  builder: (context, sSnapshot) {
                    List<Campaign> resCampaigns = [];
                    List<User> resUsers = [];
                    List<BaseSession> resSessions = [];
                    if (uSnapshot.hasData) {
                      resUsers.addAll(uSnapshot.data);
                    }
                    if (cSnapshot.hasData) {
                      resCampaigns.addAll(cSnapshot.data);
                    }

                    if (sSnapshot.hasData) {
                      resSessions.addAll(sSnapshot.data);
                    }

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
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ),
                        ..._buildUsers(resUsers),
                        SizedBox(
                          height: 10,
                        ),
                        resSessions.isEmpty
                            ? Container()
                            : Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, bottom: 10),
                                child: Text(
                                  "Sessions",
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ),
                        ..._buildSessions(resSessions),
                        SizedBox(
                          height: 10,
                        ),
                        resCampaigns.isEmpty
                            ? Container()
                            : Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, bottom: 10),
                                child: Text(
                                  "Projekte",
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ),
                        ..._buildCampaigns(resCampaigns),
                        SizedBox(height: 50)
                      ],
                    ));
                  },
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

  _buildSessions(List<BaseSession> sessions) {
    List<Widget> res = [];

    sessions.forEach((s) {
      res.add(_buildSession(s));
    });

    return res;
  }

  _buildSession(BaseSession session) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: SessionButton(
        session.id,
        textStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
        session: session,
        color: ColorTheme.appBg,
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
        elevation: 1,
        textStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
      ),
    );
  }
}
