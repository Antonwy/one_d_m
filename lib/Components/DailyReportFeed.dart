import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:one_d_m/Components/CustomOpenContainer.dart';
import 'package:one_d_m/Components/DonationWidget.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Numeral.dart';
import 'package:one_d_m/Helper/Ranking.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/NewCampaignPage.dart';
import 'package:one_d_m/Pages/ShareReportPage.dart';
import 'package:one_d_m/Pages/UserPage.dart';
import 'package:provider/provider.dart';
import 'AnimatedHomePageList.dart';

class DailyReportFeed extends StatelessWidget {
  ThemeData _theme;

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);

    final List<Widget> allWidgets = [
      ChooseDate(),
      FriendsRankingWidget(),
      CampaignsRankingWidget(),
      DailyDonatedAmountWidget(),
      SummaryWidget(),
      ShareDailyReport(),
    ];

    final List<Widget> hasDataWidgets = allWidgets;

    final List<Widget> noData = [hasDataWidgets[0], _NoData()];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      sliver: Consumer<UserManager>(
        builder: (context, um, child) => Consumer<DailyReportManager>(
          builder: (context, dm, child) => StreamBuilder<bool>(
              initialData: false,
              stream: DatabaseService.hasRankingContentForToday(um.uid,
                  date: dm.date),
              builder: (context, snapshot) {
                return SliverStaggeredGrid.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: snapshot.data ? hasDataWidgets : noData,
                  staggeredTiles: (snapshot.data ? hasDataWidgets : noData)
                      .map((e) => (e is ChooseDate || e is _NoData)
                          ? StaggeredTile.fit(2)
                          : StaggeredTile.fit(1))
                      .toList(),
                );
              }),
        ),
      ),
    );
  }
}

class _NoData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: ThemeManager.of(context).theme.darkerLight,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Consumer<DailyReportManager>(
            builder: (context, dm, child) =>
                Text("${dm.beautifyDate} keine Daten verfügbar.")),
      ),
    );
  }
}

class ChooseDate extends StatefulWidget {
  @override
  _ChooseDateState createState() => _ChooseDateState();
}

class _ChooseDateState extends State<ChooseDate>
    with AutomaticKeepAliveClientMixin {
  TextTheme _textTheme;
  PageController _pageController;

  @override
  void initState() {
    _pageController = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;
    BaseTheme _bTheme = ThemeManager.of(context).theme;
    return Material(
        borderRadius: BorderRadius.circular(12),
        color: _bTheme.darkerLight,
        clipBehavior: Clip.antiAlias,
        child: Consumer<DailyReportManager>(builder: (context, dm, child) {
          return Theme(
            data: ThemeData(primarySwatch: Colors.blueGrey).copyWith(
                dialogTheme: DialogTheme(
                    backgroundColor: _bTheme.darkerLight,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                colorScheme: Theme.of(context)
                    .colorScheme
                    .copyWith(primary: _bTheme.dark)),
            child: Builder(builder: (context) {
              return InkWell(
                onTap: () async {
                  DateTime date = await showDatePicker(
                      context: context,
                      initialDate: dm.date,
                      helpText: "Wähle Datum",
                      cancelText: "ABBRECHEN",
                      firstDate: dm.date.subtract(Duration(days: 365)),
                      lastDate: DateTime.now());
                  if (date != null) {
                    int toPage = DateTime.now().difference(date).inDays;
                    _pageController.jumpToPage(
                      toPage,
                    );
                  }
                },
                child: Container(
                  height: 60,
                  width: double.infinity,
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: Container(
                          height: 60,
                          width: 200,
                          child: PageView.builder(
                            controller: _pageController,
                            reverse: true,
                            itemCount: 365,
                            itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Row(
                                  key: Key(dm.beautifyDate),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.date_range, color: _bTheme.dark),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      DailyReportManager.staticBeautifyDate(
                                          DateTime.now()
                                              .subtract(Duration(days: index))),
                                      style: _textTheme.headline6
                                          .copyWith(color: _bTheme.dark),
                                    )
                                  ],
                                )),
                            onPageChanged: (index) {
                              dm.date = DateTime.now()
                                  .subtract(Duration(days: index));
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: IconButton(
                            icon:
                                Icon(Icons.arrow_back_ios, color: _bTheme.dark),
                            onPressed: () {
                              _animatePage(1);
                            }),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: AnimatedOpacity(
                          duration: Duration(milliseconds: 250),
                          opacity: _pageController.hasClients
                              ? _pageController.page.round() == 0 ? 0 : 1
                              : 0,
                          child: IgnorePointer(
                            ignoring: _pageController.hasClients
                                ? _pageController.page.round() == 0
                                : true,
                            child: IconButton(
                                icon: Icon(Icons.arrow_forward_ios,
                                    color: _bTheme.dark),
                                onPressed: () {
                                  _animatePage(-1);
                                }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        }));
  }

  void _animatePage(int diff) {
    _pageController.animateToPage(_pageController.page.round() + diff,
        duration: Duration(milliseconds: 500), curve: Curves.easeOut);
  }

  @override
  bool get wantKeepAlive => true;
}

class ShareDailyReport extends StatelessWidget {
  TextTheme _textTheme;
  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;
    return Consumer<DailyReportManager>(
      builder: (context, dm, child) => CustomOpenContainer(
        openBuilder: (context, close, scrollController) => ShareReportPage(
          scrollController,
          dm: dm,
        ),
        closedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        closedColor: ThemeManager.of(context).theme.darkerLight,
        closedElevation: 0,
        closedBuilder: (context, open) => Material(
            borderRadius: BorderRadius.circular(12),
            color: ThemeManager.of(context).theme.darkerLight,
            clipBehavior: Clip.antiAlias,
            child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.share),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      "Teilen",
                      style: _textTheme.headline6,
                    )
                  ],
                ))),
      ),
    );
  }
}

class DailyDonatedAmountWidget extends StatelessWidget {
  TextTheme _textTheme;
  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;
    BaseTheme _bTheme = ThemeManager.of(context).theme;
    return Material(
        borderRadius: BorderRadius.circular(12),
        color: _bTheme.darkerLight,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Consumer<DailyReportManager>(
                builder: (context, dm, child) => Text(
                  dm.beautifyDate,
                  style: _textTheme.headline6.copyWith(color: _bTheme.dark),
                ),
              ),
              Text(
                "Du und deine Freunde haben heute folgenden Betrag gespendet",
                style: _textTheme.caption,
              ),
              SizedBox(
                height: 18,
              ),
              Consumer2<UserManager, DailyReportManager>(
                builder: (context, um, dm, child) => StreamBuilder<int>(
                    initialData: 0,
                    stream: DatabaseService.getDailyFriendsDonationsAmount(
                        um.uid,
                        date: dm.date),
                    builder: (context, snapshot) {
                      return Text(
                        "${Numeral(snapshot.data).value()} DC",
                        style: _textTheme.headline5.copyWith(
                            color: _bTheme.dark, fontWeight: FontWeight.bold),
                      );
                    }),
              ),
            ],
          ),
        ));
  }
}

class SummaryWidget extends StatelessWidget {
  TextTheme _textTheme;
  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;
    BaseTheme _bTheme = ThemeManager.of(context).theme;
    return Material(
        borderRadius: BorderRadius.circular(12),
        color: _bTheme.darkerLight,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AutoSizeText(
                "Vielen Dank!",
                maxLines: 1,
                style: _textTheme.headline6.copyWith(color: _bTheme.dark),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                "Mit jeder Spende unterstützt du ein wohltätiges Projekt und bewirkts, dass irgendwo die Welt ein stückchen besser wird!",
                style: _textTheme.caption.copyWith(color: _bTheme.dark),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                "Dein ODM Team!",
                style: _textTheme.caption
                    .copyWith(color: _bTheme.dark, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ));
  }
}

class CampaignsRankingWidget extends StatelessWidget {
  CampaignsRanking _ranking;

  ThemeData _theme;

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    BaseTheme _bTheme = ThemeManager.of(context).theme;
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: _bTheme.darkerLight,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Consumer2<UserManager, DailyReportManager>(
          builder: (context, um, dm, child) => StreamBuilder<CampaignsRanking>(
              stream:
                  DatabaseService.getCampaignsRanking(um.uid, date: dm.date),
              builder: (context, snapshot) {
                _ranking = snapshot.data;

                if (!snapshot.hasData)
                  return Column(
                    children: <Widget>[
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(_bTheme.dark),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Text("Lade Rankings..."),
                    ],
                  );

                if (_ranking.topRank.isEmpty) return Text("Noch keine Daten.");

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Projekte",
                      style: _theme.textTheme.headline6
                          .copyWith(color: _bTheme.dark),
                    ),
                    Text(
                      "An diese Projekte wurde am meisten gespendet.",
                      style: _theme.textTheme.caption
                          .copyWith(color: _bTheme.dark.withOpacity(.7)),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    AnimatedHomePageList(
                      _ranking.topRank,
                      isUserList: false,
                    )
                  ],
                );
              }),
        ),
      ),
    );
  }

  List<Widget> _generateChildren() {
    List<Widget> children = [];

    for (var i = 0; i < _ranking.topRank.length; i++) {
      children.add(RankingButton(
        info: _ranking.topRank[i],
        isUser: false,
      ));
    }

    return children;
  }
}

class FriendsRankingWidget extends StatelessWidget {
  FriendsRanking _ranking;

  ThemeData _theme;

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    BaseTheme _bTheme = ThemeManager.of(context).theme;
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: _bTheme.darkerLight,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Consumer2<UserManager, DailyReportManager>(
          builder: (context, um, dm, child) => StreamBuilder<FriendsRanking>(
              stream: DatabaseService.getFriendsRanking(um.uid, date: dm.date),
              builder: (context, snapshot) {
                _ranking = snapshot.data;

                if (!snapshot.hasData)
                  return Column(
                    children: <Widget>[
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(_bTheme.dark),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Text("Lade Rankings..."),
                    ],
                  );

                if (_ranking.topRank.isEmpty) return Text("Noch keine Daten.");

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Freunde",
                      style: _theme.textTheme.headline6
                          .copyWith(color: _bTheme.dark),
                    ),
                    Text(
                      "Das haben du und deine Freunde bis jetzt erreicht.",
                      style: _theme.textTheme.caption
                          .copyWith(color: _bTheme.dark.withOpacity(.7)),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    AnimatedHomePageList(_ranking.topRank),
                  ],
                );
              }),
        ),
      ),
    );
  }

  List<Widget> _generateChildren() {
    List<Widget> children = [];

    for (var i = 0; i < _ranking.topRank.length; i++) {
      children.add(RankingButton(
        info: _ranking.topRank[i],
      ));
    }

    return children;
  }
}

class RankingButton extends StatelessWidget {
  final DonatedAmount info;
  final bool isUser;

  bool operator ==(element) {
    return element is RankingButton &&
        element.info.id == info.id &&
        element.info.amount == info.amount;
  }

  RankingButton({Key key, this.info, this.isUser = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isUser)
      return FutureBuilder(
          future: DatabaseService.getUser(info.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return _loading();

            User user = snapshot.data;
            return CustomOpenContainer(
              closedColor: ThemeManager.of(context).theme.darkerLight,
              closedElevation: 0,
              openBuilder: (context, close, controller) => UserPage(
                user,
                scrollController: controller,
              ),
              closedBuilder: (context, open) => _tile(
                  imageUrl: user?.imgUrl,
                  name: user?.name,
                  amount: info?.amount,
                  onTap: open),
            );
          });

    return FutureBuilder<Campaign>(
        future: DatabaseService.getCampaign(info.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return _loading();
          Campaign campaign = snapshot.data;

          return CustomOpenContainer(
            closedColor: ThemeManager.of(context).theme.darkerLight,
            closedElevation: 0,
            openBuilder: (context, close, controller) => NewCampaignPage(
              campaign,
              scrollController: controller,
            ),
            closedBuilder: (context, open) =>
                LayoutBuilder(builder: (context, constraints) {
              return _tile(
                  imageUrl: campaign?.imgUrl,
                  name: campaign?.name,
                  amount: campaign?.amount,
                  onTap: open);
            }),
          );
        });
  }

  Widget _tile(
      {String imageUrl,
      String name,
      int amount,
      Function onTap,
      bool withLoading = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: GestureDetector(
        onTap: onTap,
        child: LayoutBuilder(builder: (context, constraints) {
          return Row(
            children: <Widget>[
              Container(
                  height: constraints.maxWidth * .3,
                  child: RoundedAvatar(
                    imageUrl,
                    loading: withLoading,
                  )),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AutoSizeText(
                      "${name}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.w500, color: ColorTheme.blue),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    AutoSizeText(
                      "${Numeral(info.amount).value()} DC",
                      maxLines: 1,
                      maxFontSize: 12,
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: ColorTheme.blue.withOpacity(.75)),
                    ),
                  ],
                ),
              )
            ],
          );
        }),
      ),
    );
  }

  Widget _loading() {
    return _tile(
        imageUrl: null,
        name: "Laden...",
        amount: info.amount,
        withLoading: true);
  }
}

class DailyReportManager extends ChangeNotifier {
  static final DailyReportManager _manager = DailyReportManager._internal();
  DateTime _date;

  factory DailyReportManager() => _manager;

  DailyReportManager._internal() {
    _date = DateTime.now();
  }

  DateTime get date => _date;
  set date(DateTime dt) {
    _date = dt;
    notifyListeners();
  }

  String get formattedDate => Ranking.getFormatedDate(date);
  String get readableDate => "${date.day}.${date.month}.${date.year}";
  String get beautifyDate => staticBeautifyDate(date);

  static String staticBeautifyDate(DateTime dt) {
    int diffDays = dt.difference(DateTime.now()).inDays;

    if (diffDays == 0) return "Heute";
    if (diffDays == -1) return "Gestern";
    return "${dt.day}.${dt.month}.${dt.year}";
  }
}
