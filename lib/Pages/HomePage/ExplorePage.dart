import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/CampaignList.dart';
import 'package:one_d_m/Components/SearchPage.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/CategoryDialog.dart';
import 'package:one_d_m/Helper/CertifiedSessionsList.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Donation.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/speed_scroll_physics.dart';
import 'package:one_d_m/Pages/FindFriendsPage.dart';

class ExplorePage extends StatefulWidget {
  final ScrollController scrollController;

  const ExplorePage({Key key, this.scrollController}) : super(key: key);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with AutomaticKeepAliveClientMixin {
  TextTheme textTheme;
  ThemeManager _theme;
  int _categoryId = 100;

  @override
  Widget build(BuildContext context) {
    textTheme = Theme.of(context).textTheme;
    _theme = ThemeManager.of(context);

    return Scaffold(
      backgroundColor: ColorTheme.appBg,
      body: CustomScrollView(
        controller: widget.scrollController,
        physics: CustomPageViewScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.transparent,
            centerTitle: false,
            automaticallyImplyLeading: false,
            flexibleSpace: SafeArea(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: AutoSizeText("Entdecken",
                                style: textTheme.headline6),
                          ),
                          IconButton(
                              icon: Icon(
                                CupertinoIcons.search,
                                color: _theme.colors.dark,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SearchPage()));
                              }),
                          IconButton(
                              icon: Icon(
                                CupertinoIcons.person_add,
                                color: _theme.colors.dark,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            FindFriendsPage()));
                              }),
                          IconButton(
                            icon: Stack(
                              clipBehavior: Clip.antiAlias,
                              children: [
                                Center(child: Icon(Icons.filter_alt_rounded)),
                                _categoryId != 100
                                    ? Positioned(
                                        right: 0,
                                        top: -5,
                                        child: Material(
                                          shape: CircleBorder(),
                                          color: Colors.red,
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text(
                                              "1",
                                              style: _theme
                                                  .textTheme.light.bodyText2
                                                  .copyWith(fontSize: 10),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container()
                              ],
                            ),
                            onPressed: () async {
                              int resIndex = await CategoryDialog.of(context,
                                      initialIndex: _categoryId)
                                  .show();
                              setState(() {
                                _categoryId = resIndex;
                              });
                            },
                            color: _theme.colors.dark,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
              padding: const EdgeInsets.only(bottom: 6, top: 6),
              sliver: CertifiedSessionsList()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0, bottom: 10.0, top: 8),
              child: Text(
                'Projekte',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          ),
          StreamBuilder<List<Campaign>>(
              stream: _categoryId == 100
                  ? DatabaseService.getTopCampaignsStream()
                  : DatabaseService.getCampaignsFromCategoryStream(_categoryId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return CampaignList(
                    campaigns: snapshot.data,
                  );
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
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
  }
}
