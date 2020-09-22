import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/CampaignHeader.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Organisation.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:url_launcher/url_launcher.dart';

class OrganisationPage extends StatelessWidget {
  Organisation organisation;
  ThemeData _theme;
  ScrollController scrollController;

  OrganisationPage(this.organisation, {this.scrollController});

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    return Scaffold(
      backgroundColor: ColorTheme.whiteBlue,
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: ColorTheme.whiteBlue,
            iconTheme: IconThemeData(color: ColorTheme.blue),
            title: Text(
              organisation.name,
              style: TextStyle(color: ThemeManager.of(context).theme.dark),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    child: CachedNetworkImage(imageUrl: organisation.imgUrl),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    organisation.description,
                    style: _theme.textTheme.bodyText2,
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OutlineButton(
                      child: Text("Mehr Informationen"),
                      onPressed: () async {
                        if (await canLaunch(organisation.website)) {
                          launch(organisation.website);
                        }
                      },
                    ),
                  ),
                  Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "Projekte dieser Organisation:",
                        style: _theme.textTheme.headline6,
                      )),
                ],
              ),
            ),
          ),
          StreamBuilder<List<Campaign>>(
              stream:
                  DatabaseService.getCampaignsOfOrganisation(organisation.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return SliverToBoxAdapter(
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(
                            width: 20,
                          ),
                          Text("Laden..."),
                        ],
                      ),
                    )),
                  );

                if (snapshot.data.isEmpty)
                  return SliverToBoxAdapter(
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child:
                          Text("Diese Organisation hat noch keine Campagnen."),
                    )),
                  );
                return SliverList(
                    delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            CampaignHeader(snapshot.data[index]),
                        childCount: snapshot.data.length));
              })
        ],
      ),
    );
  }
}
