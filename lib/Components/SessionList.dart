import 'dart:math';

import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:provider/provider.dart';

import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:one_d_m/Pages/HomePage/ProfilePage.dart';
import 'package:one_d_m/Pages/SessionPage.dart';

import 'InfoFeed.dart';

class SessionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: StreamBuilder<List<BaseSession>>(
          initialData: [],
          stream: DatabaseService.getSessions(5),
          builder: (context, snapshot) {
            int minSessionsToShow = 2;
            int length = min(minSessionsToShow, snapshot.data?.length ?? 0);
            bool showSessionHolder = snapshot.data.length > minSessionsToShow;

            snapshot.data.sort();

            return Container(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (context, index) => SizedBox(
                    width: 8,
                  ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                          left: index == 0 ? 12.0 : 0.0,
                          right: index == length ? 12.0 : 0.0),
                      child: index == length
                          ? showSessionHolder
                              ? SessionHolder(
                                  snapshot.data,
                                  minSessionsToShow: minSessionsToShow,
                                )
                              : SizedBox.shrink()
                          : SessionView(snapshot.data[index]),
                    );
                  },
                  itemCount: length == 0 ? length : length + 1,
                ));
          }),
    );
  }
}

class SessionHolder extends StatelessWidget {
  final List<BaseSession> sessions;
  final int minSessionsToShow;

  const SessionHolder(this.sessions, {this.minSessionsToShow = 3});

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    sessions.sort();
    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: OpenContainer(
            closedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Constants.radius)),
            closedColor: _theme.colors.contrast,
            openBuilder: (context, close) => LongSessionList(sessions),
            closedBuilder: (context, open) =>
                LayoutBuilder(builder: (context, contraints) {
                  return Wrap(
                    children: _buildGrid(
                        itemSize: contraints.maxWidth / 2,
                        context: context,
                        theme: _theme,
                        open: open),
                  );
                })),
      ),
    );
  }

  List<Widget> _buildGrid(
      {double itemSize,
      BuildContext context,
      ThemeManager theme,
      Function open}) {
    List<Widget> widgets = [];
    double padding = 10, halfPadding = padding / 2;

    List<BaseSession> shortedSessions = sessions.sublist(minSessionsToShow);

    int i;

    EdgeInsets paddingFromI(int i) => EdgeInsets.fromLTRB(
        i % 2 == 0 ? padding : halfPadding,
        i < 2 ? padding : halfPadding,
        (i + 1) % 2 == 0 ? padding : halfPadding,
        i > 1 ? padding : halfPadding);

    for (i = 0; i < shortedSessions.length; i++) {
      BaseSession session = shortedSessions[i];
      widgets.add(Container(
          width: itemSize,
          height: itemSize,
          child: Padding(
            padding: paddingFromI(i),
            child: Material(
              borderRadius: BorderRadius.circular(Constants.radius - 4),
              clipBehavior: Clip.antiAlias,
              color: session.primaryColor,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SessionPage(session)));
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: session.imgUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => session?.blurHash != null
                          ? BlurHash(hash: session.blurHash)
                          : Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(theme
                                    .correctColorFor(session.primaryColor)),
                              ),
                            ),
                    ),
                    if (session.isCertified)
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Icon(
                          Icons.verified,
                          color: Colors.greenAccent[400],
                          size: 16,
                        ),
                      )
                  ],
                ),
              ),
            ),
          )));
    }

    widgets.add(Container(
      width: itemSize,
      height: itemSize,
      child: Padding(
        padding: paddingFromI(i),
        child: Material(
          borderRadius: BorderRadius.circular(Constants.radius - 4),
          color: theme.colors.dark.withOpacity(.15),
          child: Icon(
            Icons.more_horiz,
            color: theme.colors.dark,
          ),
        ),
      ),
    ));

    return widgets;
  }
}

class LongSessionList extends StatefulWidget {
  final List<BaseSession> sessions;

  const LongSessionList(this.sessions);

  @override
  _LongSessionListState createState() => _LongSessionListState();
}

class _LongSessionListState extends State<LongSessionList> {
  Future<List<BaseSession>> _sessionFuture;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _sessionFuture = DatabaseService.getSessionsFuture();
  }

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return Scaffold(
      backgroundColor: _theme.colors.contrast,
      body: ChangeNotifierProvider<LongSessionListManager>(
          create: (context) => LongSessionListManager(
              sessions: widget.sessions,
              sessionsFuture: _sessionFuture,
              textController: _controller,
              context: context),
          builder: (context, snapshot) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: IconThemeData(color: _theme.colors.textOnContrast),
                  automaticallyImplyLeading: false,
                  title: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 56,
                        child: Material(
                          color: ColorTheme.appBg,
                          elevation: 1,
                          borderRadius: BorderRadius.circular(Constants.radius),
                          child: Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 6.0, right: 6),
                                child: AppBarButton(
                                  icon: Icons.arrow_back,
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                              Expanded(
                                  child: TextField(
                                controller: _controller,
                                cursorColor: _theme.colors.dark,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Suchen"),
                                style: _theme.textTheme.dark.bodyText1
                                    .copyWith(fontSize: 18),
                              )),
                              Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: Consumer<LongSessionListManager>(
                                  builder: (context, lsm, child) {
                                    if (lsm.loading)
                                      return AppBarButton(
                                        child: Container(
                                          width: 40,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: AspectRatio(
                                                aspectRatio: 1,
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                          _theme.colors.dark),
                                                )),
                                          ),
                                        ),
                                        onPressed: null,
                                      );

                                    return AppBarButton(
                                      icon: lsm.showDeleteAllIcon
                                          ? Icons.close
                                          : CupertinoIcons.search,
                                      onPressed: lsm.showDeleteAllIcon
                                          ? lsm.deleteText
                                          : null,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      YMargin(6),
                      Consumer<LongSessionListManager>(
                          builder: (context, lsm, child) => Container(
                                height: 28,
                                child: ListView.separated(
                                  separatorBuilder: (context, index) =>
                                      XMargin(6),
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    FilterTag tag = lsm.tags[index];
                                    return Material(
                                      borderRadius: BorderRadius.circular(24),
                                      color: tag.filtered
                                          ? _theme.colors.dark
                                          : ColorTheme.appBg,
                                      elevation: 1,
                                      clipBehavior: Clip.antiAlias,
                                      child: InkWell(
                                        onTap: () {
                                          lsm.toggleTag(tag);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0, vertical: 6),
                                          child: Row(
                                            children: [
                                              if (tag.icon != null)
                                                Icon(
                                                  tag.icon,
                                                  size: 14,
                                                  color: tag.filtered
                                                      ? tag.iconColor != null
                                                          ? tag.iconColor
                                                          : _theme
                                                              .colors.textOnDark
                                                      : _theme.colors.dark,
                                                ),
                                              if (tag.icon != null) XMargin(4),
                                              Text(
                                                tag.tag,
                                                style: (tag.filtered
                                                        ? _theme.textTheme
                                                            .textOnDark
                                                        : _theme.textTheme.dark)
                                                    .bodyText1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  itemCount: lsm.tags.length,
                                ),
                              ))
                    ],
                  ),
                  toolbarHeight: 100,
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 24),
                  sliver: Consumer<LongSessionListManager>(
                      builder: (context, lsm, child) {
                    return FutureBuilder<List<BaseSession>>(
                        initialData: widget.sessions,
                        future: lsm.sessionsFuture,
                        builder: (context, snapshot) {
                          List<BaseSession> sessions = snapshot.data;

                          if (sessions.isEmpty &&
                              snapshot.hasData &&
                              snapshot.connectionState ==
                                  ConnectionState.done) {
                            return SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 48.0),
                                child: Column(
                                  children: [
                                    SvgPicture.asset(
                                        "assets/images/no-search-results.svg",
                                        height: 150),
                                    YMargin(12),
                                    Text(
                                      "Keine Sessions gefunden",
                                      style: _theme
                                          .textTheme.textOnContrast.bodyText1,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          sessions.sort();
                          return SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 1,
                                      mainAxisSpacing: 6,
                                      crossAxisSpacing: 6),
                              delegate: SliverChildBuilderDelegate(
                                  (context, index) =>
                                      SessionView(snapshot.data[index]),
                                  childCount: snapshot.data.length));
                        });
                  }),
                )
              ],
            );
          }),
    );
  }
}

class LongSessionListManager extends ChangeNotifier {
  final List<BaseSession> sessions;
  final TextEditingController textController;
  final BuildContext context;
  Future<List<BaseSession>> sessionsFuture;
  String _lastText = "";
  List<FilterTag> tags = [
    FilterTag(
        tag: "Zertifizierte",
        icon: Icons.verified,
        iconColor: Colors.greenAccent[400],
        type: FilterTagType.certified),
    FilterTag(
        tag: "Von mir", icon: Icons.person, type: FilterTagType.mySession),
  ];
  bool loading = false;

  LongSessionListManager(
      {this.sessions, this.sessionsFuture, this.textController, this.context}) {
    textController.addListener(_listenForTextChanges);
  }

  bool get showDeleteAllIcon => textController.text.isNotEmpty;

  void _listenForTextChanges() {
    if (textController.text.isEmpty && _lastText.length == 0) return;
    if (textController.text.isEmpty && _lastText.length > 0) {
      sessionsFuture = Future.value(sessions);
      _lastText = textController.text;
      return;
    }
    _lastText = textController.text;
    callQuery();
  }

  void deleteText() => textController.text = "";

  void toggleTag(FilterTag tag) {
    tag.filtered = !tag.filtered;
    callQuery();
  }

  void callQuery() {
    sessionsFuture = DatabaseService.getSessionsFromQuery(textController.text,
        onlyCertified: tags[0].filtered,
        onlySessionsFrom:
            tags[1].filtered ? context.read<UserManager>().uid : null)
      ..whenComplete(() {
        loading = false;
        notifyListeners();
      });
    loading = true;
    notifyListeners();
  }
}

enum FilterTagType { certified, mySession }

class FilterTag {
  final String tag;
  bool filtered;
  final IconData icon;
  final Color iconColor;
  final FilterTagType type;

  FilterTag(
      {this.tag, this.filtered = false, this.icon, this.iconColor, this.type});

  factory FilterTag.certified() => FilterTag(type: FilterTagType.certified);
  factory FilterTag.mySessions() => FilterTag(type: FilterTagType.mySession);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FilterTag && other.type == type;
  }

  @override
  int get hashCode {
    return type.hashCode;
  }
}

class SessionView extends StatelessWidget {
  final BaseSession session;

  SessionView(this.session);

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    Color textColor =
        _theme.correctColorFor(session?.secondaryColor ?? _theme.colors.dark);

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Material(
        borderRadius: BorderRadius.circular(Constants.radius),
        clipBehavior: Clip.antiAlias,
        color: session?.secondaryColor ?? _theme.colors.dark,
        elevation: 1,
        child: InkWell(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SessionPage(session)));
          },
          child: SizedBox(
            width: 230,
            child: Column(
              children: [
                Expanded(
                  flex: 10,
                  child: CachedNetworkImage(
                    imageUrl: session?.imgUrl ?? "",
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => session?.blurHash != null
                        ? BlurHash(hash: session.blurHash)
                        : Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(textColor),
                            ),
                          ),
                  ),
                ),
                Flexible(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: Row(
                          children: [
                            Flexible(
                              flex: 6,
                              child: AutoSizeText(
                                session?.name ?? "",
                                style: _theme.textTheme
                                    .withColor(textColor)
                                    .bodyText1,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (session.isCertified) XMargin(4),
                            if (session.isCertified)
                              Icon(
                                Icons.verified,
                                color: Colors.greenAccent[400],
                                size: 16,
                              )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(8, 0, 14, 0),
                        child: Row(
                          children: session?.donationUnit == null
                              ? [
                                  Text(
                                    "0%",
                                    style: _theme.textTheme
                                        .withColor(textColor)
                                        .bodyText2,
                                  ),
                                  XMargin(12),
                                  Expanded(
                                    child: PercentLine(
                                      percent: 0,
                                      height: 8.0,
                                      color: textColor,
                                    ),
                                  ),
                                ]
                              : [
                                  Text(
                                    "${((session.donationGoalCurrent / session.donationGoal) * 100).round()}%",
                                    style: _theme.textTheme
                                        .withColor(textColor)
                                        .bodyText2,
                                  ),
                                  XMargin(12),
                                  Expanded(
                                    child: PercentLine(
                                      percent: (session.donationGoalCurrent /
                                              session.donationGoal)
                                          .clamp(0.0, 1.0),
                                      height: 8.0,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
