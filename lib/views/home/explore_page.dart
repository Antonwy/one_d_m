import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/api/stream_result.dart';
import 'package:one_d_m/components/campaign_list.dart';
import 'package:one_d_m/components/category_dialog.dart';
import 'package:one_d_m/components/discovery_holder.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/components/sessions/sessions_list.dart';
import 'package:one_d_m/components/warning_icon.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/models/campaign_models/base_campaign.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/views/general/search_page.dart';
import 'package:one_d_m/views/home/profile_page.dart';
import 'package:one_d_m/views/sessions/create_session_page.dart';
import 'package:one_d_m/views/users/find_friends_page.dart';

class ExplorePage extends StatefulWidget {
  final ScrollController? scrollController;

  const ExplorePage({Key? key, this.scrollController}) : super(key: key);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with AutomaticKeepAliveClientMixin {
  late ThemeData theme;
  int? _categoryId = 100;
  Stream<StreamResult<List<BaseCampaign?>>>? _campaignsStream;

  @override
  void initState() {
    super.initState();

    _campaignsStream = Api().campaigns().streamGet();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        controller: widget.scrollController,
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: _theme.backgroundColor,
            centerTitle: false,
            automaticallyImplyLeading: false,
            pinned: true,
            flexibleSpace: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: AutoSizeText("Entdecken",
                          style: _theme.textTheme.headline6),
                    ),
                    AppBarButton(
                        icon: CupertinoIcons.search,
                        color: _theme.backgroundColor,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchPage()));
                        }),
                    AppBarButton(
                        icon: CupertinoIcons.person_add,
                        color: _theme.backgroundColor,
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
                        color: _theme.colorScheme.onPrimary,
                      ),
                      child: AppBarButton(
                          icon: Icons.add,
                          text: "Session erstellen",
                          iconColor: _theme.colorScheme.onSecondary,
                          color: _theme.colorScheme.secondary,
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
                      color: _theme.colorScheme.onPrimary,
                    ),
                    child: Text(
                      'Projekte',
                      style: _theme.textTheme.headline6,
                    ),
                  ),
                  AppBarButton(
                    hint: _categoryId != 100 ? 1 : 0,
                    icon: Icons.filter_alt_rounded,
                    color: _theme.backgroundColor,
                    onPressed: () async {
                      int? resIndex = await CategoryDialog.of(context,
                              initialIndex: _categoryId)
                          .show();
                      setState(() {
                        _categoryId = resIndex;
                        _campaignsStream = _categoryId != 100
                            ? Api()
                                .campaigns()
                                .category(_categoryId)
                                .streamGet()
                            : Api().campaigns().streamGet();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder<StreamResult<List<BaseCampaign?>>>(
              stream: _campaignsStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return CampaignList(
                    campaigns: snapshot.data!.data,
                  );
                }

                return SliverToBoxAdapter(
                  child: Center(
                      child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 20,
                        ),
                        snapshot.hasError ? WarningIcon() : LoadingIndicator(),
                        SizedBox(
                          height: 18,
                        ),
                        Text(
                          snapshot.hasError
                              ? "Beim Laden der Projekte ist ein Fehler ist aufgetreten!\nVersuche es später erneut."
                              : "Lade Projekte",
                          style: _theme.textTheme.caption,
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  )),
                );
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
