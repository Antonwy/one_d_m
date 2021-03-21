import 'package:flutter/material.dart';
import 'package:one_d_m/Components/OrganisationButton.dart';
import 'package:one_d_m/Components/UserButton.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Organisation.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:provider/provider.dart';
import 'CampaignButton.dart';

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
                return FutureBuilder<List<Organisation>>(
                  future: DatabaseService.getOrganisationsFromQuery(query),
                  builder: (context, oSnapshot) {
                    List<Campaign> resCampaigns = List();
                    List<User> resUsers = List();
                    List<Organisation> resOrganisations = List();
                    if (uSnapshot.hasData) {
                      resUsers.addAll(uSnapshot.data);
                    }
                    if (cSnapshot.hasData) {
                      resCampaigns.addAll(cSnapshot.data);
                    }

                    if (oSnapshot.hasData) {
                      resOrganisations.addAll(oSnapshot.data);
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
                        resOrganisations.isEmpty
                            ? Container()
                            : Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, bottom: 10),
                                child: Text(
                                  "Organisationen",
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ),
                        ..._buildOrganisations(resOrganisations),
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

                    return SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
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

  _buildOrganisations(List<Organisation> organisations) {
    List<Widget> res = [];

    organisations.forEach((c) {
      res.add(_buildOrganisation(c));
    });

    return res;
  }

  _buildOrganisation(Organisation organisation) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: OrganisationButton(
        organisation.id,
        textStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
        organisation: organisation,
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
        textStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
      ),
    );
  }
}
