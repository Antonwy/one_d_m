import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/CampaignList.dart';
import 'package:one_d_m/Components/CategoriesList.dart';
import 'package:one_d_m/Components/SearchBar.dart';
import 'package:one_d_m/Helper/CampaignsManager.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:provider/provider.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with AutomaticKeepAliveClientMixin {
  TextTheme textTheme;
  int _categoryId = 4;

  Stream<List<User>> _userStream;

  @override
  void initState() {
    _userStream = DatabaseService.getUsersStream();
    super.initState();
  }

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
                    child: SearchBar(),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
              height: 95,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: CategoriesList((catId) {
                setState(() {
                  _categoryId = catId;
                });
              })),
        ),
        Consumer<CampaignsManager>(builder: (context, cm, child) {
          return CampaignList(
            campaigns: cm.getCampaignFromCategoryId(_categoryId),
          );
        })
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
