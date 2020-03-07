import 'package:flutter/material.dart';
import 'package:one_d_m/Components/ApiBuilder.dart';
import 'package:one_d_m/Components/CampaignHeader.dart';
import 'package:one_d_m/Components/ErrorText.dart';
import 'package:one_d_m/Components/SearchBar.dart';
import 'package:one_d_m/Helper/API/Api.dart';
import 'package:one_d_m/Helper/API/ApiResult.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Pages/CampaignPage.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with AutomaticKeepAliveClientMixin<ExplorePage> {
  TextTheme textTheme;

  List<Campaign> campaigns;

  String searchQuery = "";

  Future<ApiResult> _future;

  @override
  void initState() {
    _future = Api.getCampaigns();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    textTheme = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: Colors.white,
          centerTitle: false,
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: Size(0, 70),
            child: Container(),
          ),
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Entdecken", style: textTheme.title),
                  SizedBox(
                    height: 10,
                  ),
                  SearchBar(onChanged: (String text) {
                    setState(() {
                      searchQuery = text;
                    });
                  }),
                ],
              ),
            ),
          ),
        ),
        ApiBuilder<List<Campaign>>(
            future: _future,
            success: (context, camp) {
              this.campaigns = camp
                  .where((Campaign c) =>
                      c.name.toLowerCase().contains(searchQuery.toLowerCase()))
                  .toList();
              return SliverList(
                delegate: SliverChildListDelegate(_buildChildren(context)),
              );
            },
            loading: SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            error: (context, message) => SliverFillRemaining(
                  child: Center(child: ErrorText(message)),
                )),
      ],
    );
  }

  List<Widget> _buildChildren(BuildContext context) {
    List<Widget> list = [];

    for (Campaign c in campaigns) {
      list.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
        child: Column(
          children: <Widget>[
            Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CampaignPage(campaign: c)));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CampaignHeader(c),
                  ),
                )),
          ],
        ),
      ));
    }

    list.add(SizedBox(
      height: 100,
    ));

    return list;
  }

  @override
  bool get wantKeepAlive => true;
}
