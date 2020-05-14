import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/Components/NewsPost.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/User.dart';
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
  Future<List<News>> _newsFuture;
  List<String> _subscribedCampaigns = [];

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          brightness: Brightness.dark,
          elevation: 0,
          backgroundColor: ColorTheme.blue,
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Neuigkeiten",
                style:
                    _textTheme.headline6.copyWith(color: ColorTheme.whiteBlue),
              ),
              Text(
                "Updates deiner abonnierten Projekte",
                style:
                    _textTheme.bodyText1.copyWith(color: ColorTheme.whiteBlue),
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
            return StreamBuilder<User>(
                initialData: um.user,
                stream: DatabaseService.getUserStream(um.uid),
                builder: (context, snapshot) {
                  User user = snapshot.data;
                  if (user?.subscribedCampaignsIds != null &&
                      user?.subscribedCampaignsIds != _subscribedCampaigns)
                    _newsFuture = DatabaseService.getNews(user);

                  _subscribedCampaigns = user?.subscribedCampaignsIds ?? [];
                  return FutureBuilder<List<News>>(
                      future: _newsFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return SliverFillRemaining(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                        if (_subscribedCampaigns.isEmpty)
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
                                    "Du hast noch keine abonnierten Projekte!",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  )
                                ],
                              ),
                            ),
                          );

                        if (snapshot.data.isEmpty)
                          return SliverFillRemaining(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 50,
                                  ),
                                  Image.asset(
                                      "assets/images/clip-virtual-reality.png"),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                      "Keins deiner abonnierten Projekte hat bis jetzt etwas gepostet!")
                                ],
                              ),
                            ),
                          );
                        return SliverPadding(
                          padding: EdgeInsets.only(top: 10),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate(snapshot.data
                                .map((News news) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18),
                                      child: NewsPost(news),
                                    ))
                                .toList()),
                          ),
                        );
                      });
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
