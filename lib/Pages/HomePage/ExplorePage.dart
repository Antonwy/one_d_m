import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/CampaignList.dart';
import 'package:one_d_m/Components/SearchBar.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/CertifiedSessionsList.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Donation.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/speed_scroll_physics.dart';

class ExplorePage extends StatefulWidget {
  final ScrollController scrollController;

  const ExplorePage({Key key, this.scrollController}) : super(key: key);
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
      controller: widget.scrollController,
      physics: CustomPageViewScrollPhysics(),
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: Colors.transparent,
          centerTitle: false,
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: Size(0, 80),
            child: Container(),
          ),
          actions: [_buildLatestDonations()],
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
    );
  }

  Widget _buildLatestDonations() => Container(
        height: 100,
        margin: const EdgeInsets.only(right: 12),
        child: StreamBuilder(
          stream: DatabaseService.getLatestDonations(),
          builder: (_, snapshot) {
            if (!snapshot.hasData) return SizedBox.shrink();
            List<Donation> d = snapshot.data;
            if (d.isEmpty) return SizedBox.shrink();

            d.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            d = d.reversed.toList();
            return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < d.length; i++)
                    _buildDonationAmount(
                        amount: d[i]?.amount.toString() ?? 0,
                        uid: d[i]?.userId ?? '',
                        index: d.length - i - 1)
                ]);
          },
        ),
      );

  Widget _buildDonationAmount({String uid, String amount, int index}) {
    Color textColor = Colors.black;
    if (index == 0) textColor = textColor;
    if (index == 1) textColor = textColor.withOpacity(0.7);
    if (index == 2) textColor = textColor.withOpacity(0.2);

    return FutureBuilder(
      future: DatabaseService.getUser(uid),
      builder: (_, snapshot) {
        if (!snapshot.hasData) return SizedBox.shrink();
        User u = snapshot.data;
        return RichText(
          text: TextSpan(
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 12, color: textColor),
              children: [
                TextSpan(text: '${u.name} spendete '),
                TextSpan(
                    text: '$amount DV',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ))
              ]),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
  }
}
