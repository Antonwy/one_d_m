import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/components/no_internet.dart';
import 'package:one_d_m/components/sessions/session_view.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/models/session_models/base_session.dart';
import 'package:one_d_m/provider/long_session_list_manager.dart';
import 'package:one_d_m/views/home/profile_page.dart';
import 'package:provider/provider.dart';

class LongSessionList extends StatefulWidget {
  final List<BaseSession?> sessions;

  const LongSessionList(this.sessions);

  @override
  _LongSessionListState createState() => _LongSessionListState();
}

class _LongSessionListState extends State<LongSessionList> {
  Future<List<BaseSession?>>? _sessionFuture;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _sessionFuture = Api().sessions().get();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    return Scaffold(
      backgroundColor: _theme.primaryColorLight,
      resizeToAvoidBottomInset: false,
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
                  automaticallyImplyLeading: false,
                  titleSpacing: 0,
                  title: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 56,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Material(
                            color: _theme.cardColor,
                            elevation: 1,
                            borderRadius:
                                BorderRadius.circular(Constants.radius),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 6.0, right: 6),
                                  child: AppBarButton(
                                    icon: Icons.arrow_back,
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                                Expanded(
                                    child: TextField(
                                  controller: _controller,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Suchen"),
                                  style: _theme.textTheme.bodyText1!
                                      .copyWith(fontSize: 18),
                                )),
                                Padding(
                                  padding: const EdgeInsets.only(right: 6.0),
                                  child: Consumer<LongSessionListManager>(
                                    builder: (context, lsm, child) {
                                      if (lsm.loading || lsm.error)
                                        return AppBarButton(
                                          child: Container(
                                            width: 40,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Center(
                                                  child: lsm.loading
                                                      ? LoadingIndicator(
                                                          size: 18)
                                                      : Icon(Icons.warning,
                                                          color: _theme
                                                              .errorColor)),
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
                      ),
                      YMargin(6),
                      Consumer<LongSessionListManager>(
                          builder: (context, lsm, child) => Container(
                                height: 35,
                                child: ListView.separated(
                                  separatorBuilder: (context, index) =>
                                      XMargin(6),
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    FilterTag tag = lsm.tags[index];
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          left: index == 0 ? 12.0 : 0,
                                          right: index == lsm.tags.length - 1
                                              ? 12
                                              : 0,
                                          bottom: 3),
                                      child: Material(
                                        borderRadius: BorderRadius.circular(24),
                                        color: tag.filtered
                                            ? _theme.colorScheme.secondary
                                            : _theme.cardColor,
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
                                                            : _theme.colorScheme
                                                                .onSecondary
                                                        : _theme.colorScheme
                                                            .secondary,
                                                  ),
                                                if (tag.icon != null)
                                                  XMargin(4),
                                                Text(
                                                  tag.tag!,
                                                  style: _theme
                                                      .textTheme.bodyText1!
                                                      .copyWith(
                                                          color: tag.filtered
                                                              ? _theme
                                                                  .colorScheme
                                                                  .onSecondary
                                                              : null),
                                                ),
                                              ],
                                            ),
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
                  toolbarHeight: 110,
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 24),
                  sliver: Consumer<LongSessionListManager>(
                      builder: (context, lsm, child) {
                    return FutureBuilder<List<BaseSession?>>(
                        initialData: widget.sessions,
                        future: lsm.sessionsFuture,
                        builder: (context, snapshot) {
                          List<BaseSession?> sessions = snapshot.data ?? [];

                          if (snapshot.hasError)
                            return SliverToBoxAdapter(
                              child: Padding(
                                  padding: const EdgeInsets.only(top: 48.0),
                                  child: NoInternet()),
                            );

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
                                      style: _theme.textTheme.bodyText1,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 1,
                                      mainAxisSpacing: 6,
                                      crossAxisSpacing: 6),
                              delegate: SliverChildBuilderDelegate(
                                  (context, index) =>
                                      SessionView(snapshot.data![index]),
                                  childCount: snapshot.data!.length));
                        });
                  }),
                )
              ],
            );
          }),
    );
  }
}

enum FilterTagType { certified, mySession, goalReached }

class FilterTag {
  final String? tag;
  bool filtered;
  final IconData? icon;
  final Color? iconColor;
  final FilterTagType? type;

  FilterTag(
      {this.tag, this.filtered = false, this.icon, this.iconColor, this.type});

  factory FilterTag.certified() => FilterTag(type: FilterTagType.certified);
  factory FilterTag.mySessions() => FilterTag(type: FilterTagType.mySession);
  factory FilterTag.goalReached() => FilterTag(type: FilterTagType.mySession);

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
