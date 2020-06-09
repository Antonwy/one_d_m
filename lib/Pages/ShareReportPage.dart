import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/Components/DailyReportFeed.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:provider/provider.dart';

class ShareReportPage extends StatelessWidget {
  ScrollController _scrollController;
  DailyReportManager dm;
  ThemeData _theme;

  ShareReportPage(this._scrollController, {this.dm});

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(controller: _scrollController, slivers: [
        SliverAppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "ODM",
            style: TextStyle(color: ColorTheme.blue),
          ),
          iconTheme: IconThemeData(color: ColorTheme.blue),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.share),
                onPressed: () async {
                  showDialog(
                      context: context,
                      child: AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        title: Text(
                          "Teilen",
                          style: TextStyle(color: ColorTheme.blue),
                        ),
                        content: Text(
                          "Mache ein Screenshot von deinem Tagesbericht und teile ihn z.B. in deiner Instagram oder Snapchat Story. Oder schicke ihn direkt an deine Freunde.",
                          style: TextStyle(color: ColorTheme.blue),
                        ),
                      ));
                })
          ],
        ),
        SliverToBoxAdapter(
          child: Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * .25,
                child: SvgPicture.asset("assets/images/share_odm.svg"),
              ),
              SizedBox(
                height: 20,
              ),
              AutoSizeText(
                "Deine Tagesübersicht",
                maxLines: 1,
                style:
                    _theme.textTheme.headline5.copyWith(color: ColorTheme.blue),
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                "vom ${dm.readableDate}",
                style: _theme.textTheme.subtitle2
                    .copyWith(color: ColorTheme.blue.withOpacity(.7)),
              ),
            ],
          ),
        ),
        ChangeNotifierProvider.value(
          value: DailyReportManager(),
          child: SliverPadding(
            padding: const EdgeInsets.all(18.0),
            sliver: SliverStaggeredGrid.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: <Widget>[
                FriendsRankingWidget(),
                CampaignsRankingWidget(),
                DailyDonatedAmountWidget(),
                SummaryWidget()
              ],
              staggeredTiles: [
                StaggeredTile.fit(1),
                StaggeredTile.fit(1),
                StaggeredTile.fit(1),
                StaggeredTile.fit(1),
              ],
            ),
          ),
        )
      ]),
    );
  }
}
