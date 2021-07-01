import 'dart:typed_data';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:one_d_m/Components/CustomTabBar.dart';
import 'package:one_d_m/Components/PushNotification.dart';
import 'package:one_d_m/Helper/AdBalance.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Donation.dart';
import 'package:one_d_m/Helper/GoalPageManager.dart';
import 'package:one_d_m/Helper/Suggestion.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:one_d_m/Pages/NewCampaignPage.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:styled_text/styled_text.dart';
import 'package:timeline_tile/timeline_tile.dart' as timeline;

class GoalPage extends StatefulWidget {
  @override
  _GoalPageState createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage>
    with AutomaticKeepAliveClientMixin {
  ThemeManager _theme;
  GoalPageTabs _currentTab = GoalPageTabs.suggestions;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(AssetImage("assets/images/forest-odm.jpg"), context);
    precacheImage(AssetImage("assets/images/forest-3-odm.jpg"), context);
  }

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return Scaffold(
      backgroundColor: ColorTheme.appBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: CustomTabBar(
                      tabs: [
                        CustomTabInfo(
                            name: "Deine Ziele",
                            title: "Deine täglichen Ziele",
                            subtitle:
                                "Wir haben dir ein paar Projekte rausgesucht, die dir vielleicht gefallen könnten!",
                            assetPath: "assets/images/forest-odm.jpg",
                            tab: GoalPageTabs.suggestions),
                        CustomTabInfo(
                            name: "Roadmap",
                            title: "Abgeschlossene Meilensteine",
                            subtitle:
                                "Diese Meilensteine haben wir mit der ODM Community bis jetzt geknackt!",
                            assetPath: "assets/images/forest-3-odm.jpg",
                            tab: GoalPageTabs.roadmap),
                      ],
                      onTabChanged: (tab) {
                        setState(() {
                          _currentTab = tab;
                        });
                        print(_currentTab);
                      }),
                )),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 250),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 1000),
                      child: LayoutBuilder(builder: (context, constraints) {
                        switch (_currentTab) {
                          case GoalPageTabs.suggestions:
                            return _Suggestions();
                          case GoalPageTabs.roadmap:
                          default:
                            return _Roadmap();
                        }
                      }),
                    ),
                  )),
            ),
            YMargin(80)
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

enum GoalPageTabs { suggestions, roadmap }

class CustomTabInfo {
  final String name, title, subtitle, assetPath;
  final GoalPageTabs tab;

  CustomTabInfo(
      {this.name, this.title, this.subtitle, this.assetPath, this.tab});
}

class _Suggestions extends StatefulWidget {
  @override
  __SuggestionsState createState() => __SuggestionsState();
}

class __SuggestionsState extends State<_Suggestions> {
  Stream<List<Donation>> _donationsFromUser;
  Future<List<Suggestion>> _suggestionsFuture;

  @override
  void initState() {
    super.initState();
    _donationsFromUser = DatabaseService.getTodaysDonationsFromUser(
        context.read<UserManager>().uid);
    _suggestionsFuture = DatabaseService.getSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: StreamBuilder<List<Donation>>(
          initialData: [],
          stream: _donationsFromUser,
          builder: (context, dSnapshot) {
            List<Donation> todaysDonation = dSnapshot.data ?? [];
            Map<String, int> donationAmountMap = {};

            for (Donation d in todaysDonation) {
              donationAmountMap.update(
                d.campaignId,
                (value) => value + d.amount,
                ifAbsent: () => d.amount,
              );
            }

            print(donationAmountMap);

            return FutureBuilder<List<Suggestion>>(
                future: _suggestionsFuture,
                builder: (context, snapshot) {
                  List<Suggestion> suggestions = snapshot.data ?? [];
                  List<Widget> _suggestionsWidgets = [];
                  List<Widget> _doneSuggestions = [];

                  suggestions.removeWhere((el) => !el.visible);

                  if (suggestions.isEmpty &&
                      snapshot.connectionState == ConnectionState.done)
                    return _buildEmptySuggestions();

                  for (Suggestion sugg in suggestions) {
                    if (sugg.onlyAdmins &&
                        !(context.read<UserManager>().user?.admin ?? false))
                      continue;

                    if (_hasAllAttributes(sugg)) {
                      sugg.donatedToday =
                          donationAmountMap[sugg.campaignId] ?? 0;
                      sugg.setDefaultColors(context);

                      (sugg.isDone ? _doneSuggestions : _suggestionsWidgets)
                          .add(Provider(
                              create: (context) => sugg,
                              child: _SuggestionBox()));
                      (sugg.isDone ? _doneSuggestions : _suggestionsWidgets)
                          .add(YMargin(12));
                    }
                  }

                  _suggestionsWidgets.addAll(_doneSuggestions);

                  _suggestionsWidgets.add(YMargin(12));

                  return Column(
                    children: _suggestionsWidgets,
                  );
                });
          }),
    );
  }

  Widget _buildEmptySuggestions() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          YMargin(12),
          SvgPicture.asset('assets/images/no-news.svg', height: 200),
          YMargin(12),
          Text(
            "Wir arbeiten hart daran, dir neue Ziele bereitzustellen",
            textAlign: TextAlign.center,
            style: ThemeManager.of(context).textTheme.dark.bodyText1,
          )
        ],
      ),
    );
  }

  bool _hasAllAttributes(Suggestion sugg) {
    return sugg.visible &&
        sugg.animationUrl != null &&
        sugg.campaignId != null &&
        sugg.campaignName != null &&
        sugg.subTitle != null &&
        sugg.title != null &&
        sugg.doneSubTitle != null &&
        sugg.doneTitle != null;
  }
}

class _SuggestionBox extends StatefulWidget {
  @override
  __SuggestionBoxState createState() => __SuggestionBoxState();
}

class __SuggestionBoxState extends State<_SuggestionBox> {
  bool _campaigLoading = false;
  final Duration _animDuration = Duration(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    Suggestion _suggestion = context.read<Suggestion>();
    bool _isDone = _suggestion.isDone;
    print("IsDONE: $_isDone");
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(Constants.radius),
      clipBehavior: Clip.antiAlias,
      child: AnimatedContainer(
        width: double.infinity,
        duration: _animDuration,
        decoration: BoxDecoration(
          color: _isDone
              ? _theme.colors.contrast.withOpacity(.5)
              : _suggestion.secondaryColor,
        ),
        child: Column(
          children: [
            AnimatedContainer(
              duration: _animDuration,
              height: 200,
              width: 400,
              color:
                  _isDone ? _theme.colors.contrast : _suggestion.primaryColor,
              child: Center(
                child: AnimatedSwitcher(
                  duration: _animDuration,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: _isDone
                        ? _SuggestionDoneWidget()
                        : _DonationAnimWidget(
                            animUrl: _suggestion.animationUrl,
                          ),
                  ),
                ),
              ),
            ),
            YMargin(12),
            StyledText(
              text: _isDone ? _suggestion.doneTitle : _suggestion.title,
              style: (_isDone
                      ? _theme.textTheme.textOnContrast
                      : _theme.textTheme.withColor(_suggestion.textOnSecondary))
                  .headline6
                  .copyWith(
                      fontSize: 25, fontWeight: FontWeight.w400, height: 1.3),
              textAlign: TextAlign.center,
              styles: {'bold': TextStyle(fontWeight: FontWeight.bold)},
            ),
            YMargin(12),
            LayoutBuilder(builder: (context, constraints) {
              return Container(
                width: constraints.maxWidth / 2,
                child: StyledText(
                  text:
                      _isDone ? _suggestion.doneSubTitle : _suggestion.subTitle,
                  style: (_isDone
                          ? _theme.textTheme.textOnContrast
                          : _theme.textTheme
                              .withColor(_suggestion.textOnSecondary))
                      .caption,
                  styles: {
                    'bold': TextStyle(fontWeight: FontWeight.bold),
                    'highlight': TextStyle(
                        color: _isDone
                            ? _theme.colors.textOnContrast
                            : _suggestion.textOnSecondary)
                  },
                  textAlign: TextAlign.center,
                ),
              );
            }),
            YMargin(12),
            Material(
              borderRadius: BorderRadius.circular(24),
              clipBehavior: Clip.antiAlias,
              child: AnimatedContainer(
                duration: _animDuration,
                color: _isDone ? _theme.colors.dark : _suggestion.primaryColor,
                child: InkWell(
                  onTap: _campaigLoading
                      ? null
                      : () async {
                          if (_suggestion.campaignId == null) return;
                          setState(() {
                            _campaigLoading = true;
                          });
                          Campaign c = await DatabaseService.getCampaign(
                              _suggestion.campaignId);

                          if (c == null) {
                            setState(() {
                              _campaigLoading = false;
                            });
                            return;
                          }
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => NewCampaignPage(c)))
                              .then((value) => setState(() {
                                    _campaigLoading = false;
                                  }));
                        },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16),
                    child: _campaigLoading
                        ? Container(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation(_isDone
                                  ? _theme.colors.textOnDark
                                  : _suggestion.textOnPrimary),
                            ),
                          )
                        : Text(
                            _suggestion.campaignName,
                            style: (_isDone
                                    ? _theme.textTheme.textOnDark
                                    : _theme.textTheme
                                        .withColor(_suggestion.textOnPrimary))
                                .bodyText1,
                          ),
                  ),
                ),
              ),
            ),
            YMargin(12),
          ],
        ),
      ),
    );
  }
}

class _SuggestionDoneWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Transform.scale(
        scale: 2,
        child: Lottie.asset('assets/anim/anim_start.json',
            fit: BoxFit.cover, repeat: false),
      ),
    );
  }
}

class _DonationAnimWidget extends StatefulWidget {
  final String animUrl;

  const _DonationAnimWidget({Key key, this.animUrl}) : super(key: key);

  @override
  _DonationAnimWidgetState createState() => _DonationAnimWidgetState();
}

class _DonationAnimWidgetState extends State<_DonationAnimWidget> {
  Future<List<Artboard>> _futureRives;
  Stream<AdBalance> _adBalanceStream;
  Suggestion _suggestion;

  @override
  void initState() {
    super.initState();
    _suggestion = context.read<Suggestion>();

    _futureRives = _loadAndCacheRives(_suggestion.amount.clamp(0, 2));
    _adBalanceStream =
        DatabaseService.getAdBalance(context.read<UserManager>().uid);
  }

  Future<List<Artboard>> _loadAndCacheRives(int amount) async {
    try {
      final cacheManager = DefaultCacheManager();
      FileInfo fileInfo = await cacheManager
          .getFileFromCache(widget.animUrl); // Get video from cache first

      if (fileInfo?.file == null) {
        fileInfo = await cacheManager.downloadFile(widget.animUrl);
      }

      Uint8List list = await fileInfo.file.readAsBytes();
      ByteData data = ByteData.view(list.buffer);
      final List<RiveFile> _riveFiles =
          List.generate(amount, (i) => RiveFile());

      bool _failedImporting = false;

      for (RiveFile _rFile in _riveFiles) {
        if (!_rFile.import(data)) _failedImporting = true;
      }

      if (_failedImporting) return null;
      return _riveFiles.map((r) => r.mainArtboard).toList();
    } catch (e) {
      print(e);
    }
  }

  BuildContext mContext;
  bool _rightDone = false;

  @override
  Widget build(BuildContext context) {
    mContext = context;
    return FutureBuilder<List<Artboard>>(
        future: _futureRives,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return SizedBox.shrink();
          }

          List<Widget> _riveBoxes = [];
          int amountDonatedTmp = _suggestion.donatedToday, _index = 0;

          print(snapshot.data.length);

          for (Artboard artboard in snapshot.data) {
            print("inDEX: $_index");
            bool isDone;
            if (_rightDone) {
              if (_index > 0)
                isDone = true;
              else
                isDone = false;
            } else {
              isDone = amountDonatedTmp >= _suggestion.amountPerDonation;
            }

            print("RightIsDone: $_rightDone, Done: $isDone");
            _riveBoxes.add(Expanded(
              child: OfflineBuilder(
                  child: Container(),
                  connectivityBuilder: (context, status, child) {
                    return StreamBuilder<AdBalance>(
                        stream: _adBalanceStream,
                        initialData: AdBalance.zero(),
                        builder: (context, s) {
                          return _RiveBox(artboard,
                              isDone: isDone,
                              onPressed: () {
                                int _i = snapshot.data.indexOf(artboard);
                                if (_i > 0) {
                                  print("Setting right done $_i");
                                  _rightDone = true;
                                }
                                _donate();
                              },
                              checkBeforeAnimate: () =>
                                  s.data.dcBalance >=
                                  _suggestion.amountPerDonation,
                              onError: () => _notEnoughDVs(),
                              shouldAnimate: status != ConnectivityResult.none);
                        });
                  }),
            ));

            amountDonatedTmp -= _suggestion.amountPerDonation;
            _index++;
          }

          return Row(children: _riveBoxes);
        });
  }

  void _notEnoughDVs() {
    print("Not enough DVs");
    NotificationContent content = NotificationContent(
        title: "Nicht genügend DVs!",
        body: "Du musst mehr DVs sammeln um zu spenden.",
        icon: Icons.warning);
    PushNotification.of(context).show(content);
  }

  void _donate() async {
    Suggestion suggestion = context.read<Suggestion>();

    UserManager um = context.read<UserManager>();

    Campaign campaign =
        await DatabaseService.getCampaign(suggestion.campaignId);
    if (um.uid == null) return;

    AdBalance adBalance = await DatabaseService.getAdBalanceFuture(um.uid);

    if (adBalance.dcBalance < (suggestion.amountPerDonation ?? 1)) {
      _notEnoughDVs();
      return;
    }

    Donation donation = Donation(suggestion.amountPerDonation ?? 1,
        campaignId: suggestion.campaignId,
        alternativeCampaignId: suggestion.campaignId,
        campaignImgUrl: campaign.imgUrl,
        userId: um.uid,
        campaignName: campaign.name,
        anonym: um.user.ghost,
        useDCs: true);

    print("Donating... $donation");
    await DatabaseService.donate(donation);

    try {
      await context
          .read<FirebaseAnalytics>()
          .logEvent(name: "Donation_from_Suggestion", parameters: {
        "amount": donation.amount,
        "campaign": donation.campaignName,
      });
    } catch (e) {
      print(e);
    }
  }
}

class _RiveBox extends StatefulWidget {
  final Artboard _artboard;
  final bool shouldAnimate, isDone;
  final void Function() onPressed;
  final bool Function() checkBeforeAnimate;
  final void Function() onError;

  _RiveBox(this._artboard,
      {this.onPressed,
      this.shouldAnimate,
      this.checkBeforeAnimate,
      this.onError,
      this.isDone = false});

  @override
  __RiveBoxState createState() => __RiveBoxState();
}

class __RiveBoxState extends State<_RiveBox> {
  bool _isUsed = false;

  @override
  void initState() {
    super.initState();
    widget._artboard
        .addController(SimpleAnimation(widget.isDone ? "used" : "idle"));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (_isUsed || !widget.shouldAnimate || widget.isDone) return;

        if (!widget.checkBeforeAnimate()) {
          widget.onError();
          return;
        }

        widget._artboard.addController(SimpleAnimation("used"));
        _isUsed = true;
        widget.onPressed();
      },
      child: Rive(
        artboard: widget._artboard,
        fit: BoxFit.contain,
        alignment: Alignment.bottomCenter,
      ),
    );
  }
}

class _Roadmap extends StatelessWidget {
  ThemeManager _theme;

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(
            children: [
              YMargin(6),
              _DropdownButton(),
              XMargin(6),
              Text(":", style: _theme.textTheme.dark.headline6),
            ],
          ),
        ),
        Consumer<GoalPageManager>(
            builder: (context, gpm, child) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: _buildGoalDescription(gpm?.goal),
                )),
        Consumer<GoalPageManager>(
          builder: (context, gpm, child) {
            return StreamBuilder<List<GoalCheckpoint>>(
                stream: gpm.goal?.checkpoints,
                builder: (context, snapshot) {
                  List<GoalCheckpoint> checkpoints = snapshot.data ?? [];
                  if (checkpoints.isNotEmpty) {
                    checkpoints.first.position = TimelinePosition.first;
                    checkpoints.last.position = TimelinePosition.last;
                  }

                  if (checkpoints.isEmpty)
                    return Center(
                      child: Column(
                        children: <Widget>[
                          YMargin(
                            20,
                          ),
                          SvgPicture.asset(
                            "assets/images/no-news.svg",
                            height: MediaQuery.of(context).size.height * .25,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Noch keine Ziele vorhanden",
                            style: _theme.textTheme.dark.bodyText1,
                          ),
                        ],
                      ),
                    );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (GoalCheckpoint check in checkpoints)
                        Builder(
                          builder: (context) {
                            bool _reached =
                                gpm.goal.currentValue >= check.value;
                            Color _color = _reached
                                ? _theme.colors.dark
                                : Colors.grey[300];
                            Color _textColor = _reached
                                ? _theme.colors.light
                                : _theme.colors.dark.withOpacity(.7);
                            return timeline.TimelineTile(
                              alignment: timeline.TimelineAlign.start,
                              isFirst: check.position == TimelinePosition.first,
                              isLast: check.position == TimelinePosition.last,
                              indicatorStyle: timeline.IndicatorStyle(
                                  width: 18,
                                  color: _color,
                                  iconStyle: timeline.IconStyle(
                                      iconData:
                                          _reached ? Icons.done : Icons.close,
                                      color: _textColor)),
                              beforeLineStyle: timeline.LineStyle(
                                color: _color,
                                thickness: 2,
                              ),
                              afterLineStyle: timeline.LineStyle(
                                color: _color,
                                thickness: 2,
                              ),
                              endChild: _TimelineContent(
                                checkpoint: check,
                                reached: gpm.goal.currentValue >= check.value,
                                color: _color,
                                textColor: _textColor,
                              ),
                            );
                          },
                        ),
                    ],
                  );
                });
          },
        ),
        YMargin(12)
      ],
    );
  }

  Widget _buildGoalDescription(Goal goal) {
    if (goal == null) return SizedBox.shrink();

    if (goal.description?.isEmpty ?? true)
      return RichText(
          text: TextSpan(style: _theme.textTheme.dark.bodyText2, children: [
        TextSpan(
          text: "Wir haben bis jetzt ",
        ),
        TextSpan(
            text: goal.currentValue.toString(),
            style: TextStyle(fontWeight: FontWeight.w800)),
        TextSpan(
          text: " ${goal.unit} gespendet.",
        ),
      ]));

    if (goal.description.contains("**")) {
      List<String> splitted = goal.description.split("**");
      return RichText(
          text: TextSpan(style: _theme.textTheme.dark.bodyText2, children: [
        TextSpan(
          text: splitted[0],
        ),
        TextSpan(
            text: "${goal.currentValue}",
            style: TextStyle(fontWeight: FontWeight.w800)),
        TextSpan(
          text: " ${goal.unit}${splitted.length >= 2 ? splitted[1] : ""}",
        ),
      ]));
    } else
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
              text: TextSpan(style: _theme.textTheme.dark.bodyText2, children: [
            TextSpan(
              text: "Wir haben bis jetzt ",
            ),
            TextSpan(
                text: goal.currentValue.toString(),
                style: TextStyle(fontWeight: FontWeight.w800)),
            TextSpan(
              text: " ${goal.unit} gespendet.",
            ),
          ])),
          Text("${goal.description}"),
        ],
      );
  }
}

class _DropdownButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return Consumer<GoalPageManager>(
      builder: (context, gpm, child) => Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.0),
          color: _theme.colors.contrast,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Goal>(
              value: gpm?.goal,
              onChanged: (val) => gpm.goal = val,
              style: _theme.textTheme.textOnContrast.headline6
                  .copyWith(fontSize: 18),
              dropdownColor: _theme.colors.contrast,
              iconEnabledColor: _theme.colors.textOnContrast,
              disabledHint: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 18,
                  height: 18,
                  child: gpm.error
                      ? Icon(
                          Icons.warning,
                          color: _theme.colors.textOnContrast,
                        )
                      : CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation(
                              _theme.colors.textOnContrast),
                        ),
                ),
              ),
              items: gpm.goals
                  .map<DropdownMenuItem<Goal>>(
                      (value) => DropdownMenuItem<Goal>(
                            value: value,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Text(
                                value.name ?? value.id,
                                style: _theme.textTheme.textOnContrast.headline6
                                    .copyWith(fontSize: 18),
                              ),
                            ),
                          ))
                  .toList()),
        ),
      ),
    );
  }
}

class _TimelineContent extends StatelessWidget {
  final GoalCheckpoint checkpoint;
  final bool reached;
  final Color color, textColor;

  const _TimelineContent(
      {Key key,
      this.checkpoint,
      this.reached = false,
      this.color,
      this.textColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    BaseTextTheme _textTheme = _theme.textTheme.withColor(textColor);

    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<GoalPageManager>(
              builder: (context, gpm, child) => Text(
                "${checkpoint.value} ${gpm.goal?.unitSmiley ?? gpm.goal?.unit ?? gpm.goal?.name ?? "DV"}",
                style: _textTheme.headline6,
              ),
            ),
            if (checkpoint.pending != null && !reached)
              Text(
                checkpoint.pending,
                style: _textTheme.bodyText1,
              ),
            if (checkpoint.done != null && reached)
              Text(
                checkpoint.done,
                style: _textTheme.bodyText1,
              ),
          ],
        ),
      ),
    );
  }
}
