import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/Components/NativeAd.dart';
import 'package:one_d_m/Components/NewsPost.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:provider/provider.dart';

class NewsHomePage extends StatefulWidget {
  Function changePage;

  NewsHomePage(this.changePage);

  @override
  _NewsHomePageState createState() => _NewsHomePageState();
}

class _NewsHomePageState extends State<NewsHomePage>
    with AutomaticKeepAliveClientMixin {
  TextTheme _textTheme;

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;

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
                stream: DatabaseService.getNews(um.uid),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );

                  List<News> news = snapshot.data;

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
                              "Du hast noch keine Neuigkeiten!",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            )
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

      if (rateCount >= adRate) {
        widgets.add(NewsNativeAd());
        rateCount = 0;
      }
    }

    return widgets;
  }

  @override
  bool get wantKeepAlive => true;
}
