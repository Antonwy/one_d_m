import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/CampaignList.dart';
import 'package:one_d_m/Components/DiscoveryHolder.dart';
import 'package:one_d_m/Components/SearchPage.dart';
import 'package:one_d_m/Components/SessionList.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/CategoryDialog.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:one_d_m/Helper/speed_scroll_physics.dart';
import 'package:one_d_m/Pages/CreateSessionPage.dart';
import 'package:one_d_m/Pages/FindFriendsPage.dart';
import 'package:one_d_m/Pages/HomePage/ProfilePage.dart';

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
            backgroundColor: ColorTheme.appBg,
            centerTitle: false,
            automaticallyImplyLeading: false,
            pinned: true,
            flexibleSpace: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child:
                          AutoSizeText("Entdecken", style: textTheme.headline6),
                    ),
                    AppBarButton(
                        icon: CupertinoIcons.search,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchPage()));
                        }),
                    AppBarButton(
                        icon: CupertinoIcons.person_add,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FindFriendsPage()));
                        }),
                    XMargin(6),
                    DiscoveryHolder.createSession(
                      tapTarget: Icon(
                        Icons.add,
                        color: _theme.colors.contrast,
                      ),
                      child: AppBarButton(
                          icon: Icons.add,
                          color: _theme.colors.dark,
                          iconColor: _theme.colors.textOnDark,
                          text: "Session erstellen",
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CreateSessionPage()));
                          }),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
              padding: const EdgeInsets.only(bottom: 6, top: 6),
              sliver: SessionList()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 12.0, bottom: 10.0, top: 8, right: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DiscoveryHolder.projectHome(
                    tapTarget: Icon(
                      Icons.done,
                      color: _theme.colors.contrast,
                    ),
                    child: Text(
                      'Projekte',
                      style: _theme.textTheme.dark.headline6,
                    ),
                  ),
                  AppBarButton(
                    hint: _categoryId != 100 ? 1 : 0,
                    icon: Icons.filter_alt_rounded,
                    onPressed: () async {
                      int resIndex = await CategoryDialog.of(context,
                              initialIndex: _categoryId)
                          .show();
                      setState(() {
                        _categoryId = resIndex;
                      });
                    },
                  ),
                ],
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
