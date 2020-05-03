import 'package:flutter/material.dart';
import 'package:one_d_m/Components/ActivityDonationFeed.dart';
import 'package:one_d_m/Components/DonationWidget.dart';
import 'package:one_d_m/Components/NewsPost.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Donation.dart';
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
          elevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Neuigkeiten",
                style: _textTheme.title,
              ),
              Text(
                "Updates deiner abonnierten Projekte",
                style: _textTheme.body1,
              ),
            ],
          ),
          centerTitle: false,
        ),
        Consumer<UserManager>(
          builder: (context, um, child) {
            return FutureBuilder<List<News>>(
                future: DatabaseService().getNews(um.user),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );

                  return SliverPadding(
                    padding: EdgeInsets.only(top: 10),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(snapshot.data
                          .map((News news) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: NewsPost(news),
                          ))
                          .toList()),
                    ),
                  );
                });
          },
        ),
        SliverPadding(padding: EdgeInsets.only(bottom: 150))
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
