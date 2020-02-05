import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/CampaignHeader.dart';
import 'package:one_d_m/Components/SearchBar.dart';
import 'package:one_d_m/Helper/Api.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Pages/CampaignPage.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  TextTheme textTheme;

  List<Campaign> campaigns;

  String searchQuery = "";

  final AsyncMemoizer<List<Campaign>> _memoizer = new AsyncMemoizer();

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
                  SearchBar(
                    onChanged: (String text) {
                      setState(() {
                        searchQuery = text;
                      });
                    }
                  ),
                ],
              ),
            ),
          ),
        ),
        FutureBuilder<List<Campaign>>(
          future: _fetchData(),
          builder: (BuildContext c, AsyncSnapshot<List<Campaign>> snapshot) {
            if(snapshot.hasData) {
              campaigns = snapshot.data.where((Campaign c) => c.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
              return SliverList(delegate: SliverChildListDelegate(_buildChildren(context)),);
            }
            return SliverFillRemaining(child: Center(child: CircularProgressIndicator(),),);
          },
        ),
      ],
    );
  }

  Future<List<Campaign>> _fetchData() {
    return _memoizer.runOnce(() async {
      return await Api.getCampaigns();
    });
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
                            builder: (context) => CampaignPage(c)));
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
}
