import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/components/native_ad.dart';
import 'package:one_d_m/components/news_post.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/helper/database_service.dart';
import 'package:one_d_m/models/news.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:provider/provider.dart';

class NewsHomePage extends StatefulWidget {
  Function changePage;

  NewsHomePage(this.changePage);

  @override
  _NewsHomePageState createState() => _NewsHomePageState();
}

class _NewsHomePageState extends State<NewsHomePage>
    with AutomaticKeepAliveClientMixin {
  late TextTheme _textTheme;
  late ThemeManager _theme;

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;
    _theme = ThemeManager.of(context);

    print("NOWWWW");

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          brightness: Brightness.dark,
          elevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Neuigkeiten",
                style: _textTheme.headline6,
              ),
              Text(
                "Updates deiner abonnierten Projekte",
                style: _textTheme.caption,
              ),
              SizedBox(
                height: 10,
              )
            ],
          ),
          centerTitle: false,
        ),
        Consumer<UserManager>(
          builder: (context, um, child) {
            return StreamBuilder<List<News>>(
                stream: DatabaseService.getNews(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );

                  List<News> news = snapshot.data!;

                  if (news.isEmpty)
                    return SliverFillRemaining(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 50,
                            ),
                            SvgPicture.asset(
                              "assets/images/no-news.svg",
                              height: 200,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Du hast noch keine Neuigkeiten!\nAbonniere Projekte um Neuigkeiten zu erhalten.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            RaisedButton(
                              onPressed: widget.changePage as void Function()?,
                              color: _theme.colors!.contrast,
                              textColor: _theme.colors!.textOnContrast,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                              child: Text("Zu den Projekten"),
                            ),
                          ],
                        ),
                      ),
                    );

                  return SliverPadding(
                    padding: EdgeInsets.only(top: 10),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(_getNewsWidget(news)),
                    ),
                  );
                });
          },
        ),
        SliverPadding(padding: EdgeInsets.only(bottom: 150))
      ],
    );
  }

  List<Widget> _getNewsWidget(List<News> news) {
    List<Widget> widgets = [];
    int adRate = Constants.AD_NEWS_RATE;
    int rateCount = 0;

    for (News n in news) {
      rateCount++;

      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: NewsPost(n),
      ));

      if (Platform.isIOS && rateCount >= adRate) {
        widgets.add(NewsNativeAd());
        rateCount = 0;
      }
    }

    return widgets;
  }

  @override
  bool get wantKeepAlive => true;
}
