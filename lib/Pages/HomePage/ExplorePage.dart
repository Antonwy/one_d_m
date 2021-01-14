import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/CampaignList.dart';
import 'package:one_d_m/Components/SearchBar.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/CertifiedSessionsList.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with AutomaticKeepAliveClientMixin {
  TextTheme textTheme;
  int _categoryId = 100;

  @override
  Widget build(BuildContext context) {
    textTheme = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: Colors.transparent,
          centerTitle: false,
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: Size(0, 80),
            child: Container(),
          ),
          flexibleSpace: SafeArea(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text("Entdecken", style: textTheme.headline6),
                  ),
                  SizedBox(
                    height: 18,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: SearchBar(
                      categoryIndex: _categoryId,
                      onCategoryChange: (index) {
                        setState(() {
                          _categoryId = index;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
            padding: const EdgeInsets.only(bottom: 6),
            sliver: CertifiedSessionsList()),
        StreamBuilder<List<Campaign>>(
            stream: _categoryId == 100
                ? DatabaseService.getTopCampaignsStream()
                : DatabaseService.getCampaignsFromCategoryStream(_categoryId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return CampaignList(campaigns: snapshot.data,);
              } else {
                return SliverToBoxAdapter(
                  child: Center(
                      child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(ColorTheme.blue),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text("Lade Projekte")
                    ],
                  )),
                );
              }
            })
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
  }
}
