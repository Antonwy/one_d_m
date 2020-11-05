import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/SessionsFeed.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/Numeral.dart';
import 'package:one_d_m/Helper/Provider/SessionManager.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/SessionPage.dart';
import 'package:provider/provider.dart';

class CertifiedSessionPage extends StatefulWidget {
  Session session;
  ScrollController scrollController;

  CertifiedSessionPage({Key key, this.session, this.scrollController})
      : super(key: key);

  @override
  _CertifiedSessionPageState createState() => _CertifiedSessionPageState();
}

class _CertifiedSessionPageState extends State<CertifiedSessionPage> {
  MediaQueryData _mq;

  ThemeManager _theme;

  ValueNotifier _scrollOffset;

  Session session;

  @override
  void initState() {
    _scrollOffset = ValueNotifier(0);
    session = widget.session;

    widget.scrollController.addListener(() {
      _scrollOffset.value = widget.scrollController.offset;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _mq = MediaQuery.of(context);
    _theme = ThemeManager.of(context);
    UserManager _um = Provider.of<UserManager>(context, listen: false);
    return Provider<CertifiedSessionManager>(
      create: (context) =>
          CertifiedSessionManager(baseSession: session, uid: _um.uid),
      builder: (context, child) {
        return Scaffold(
          body: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: _mq.size.height * .3 + 30,
                  decoration: BoxDecoration(
                      image: widget.session?.imgUrl == null
                          ? null
                          : DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                  widget.session?.imgUrl))),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ValueListenableBuilder(
                    valueListenable: _scrollOffset,
                    builder: (context, value, child) {
                      return Container(
                          height: (_mq.size.height * .7 + value)
                              .clamp(0, _mq.size.height),
                          width: double.infinity,
                          child: Material(
                            color: ColorTheme.white,
                            elevation: 20,
                            clipBehavior: Clip.antiAlias,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(30)),
                          ));
                    }),
              ),
              MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: CustomScrollView(
                    controller: widget.scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: _mq.size.height * .3,
                          child: Container(
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                      SliverPadding(
                          padding: EdgeInsets.fromLTRB(14, 18, 14, 6),
                          sliver: SliverToBoxAdapter(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: AutoSizeText(
                                    session.name,
                                    maxLines: 1,
                                    style: _theme.textTheme.dark.headline6,
                                  ),
                                ),
                                _SessionJoinButton()
                              ],
                            ),
                          )),
                      SliverToBoxAdapter(
                        child: Divider(),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(12.0, 6, 12, 6),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            children: [
                              Consumer<CertifiedSessionManager>(
                                builder: (context, csm, child) =>
                                    StreamBuilder<Session>(
                                        stream: csm.sessionStream,
                                        builder: (context, snapshot) {
                                          return _InfoView(
                                            description: "DC",
                                            value:
                                                snapshot.data?.currentAmount ??
                                                    session.currentAmount,
                                          );
                                        }),
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              Consumer<CertifiedSessionManager>(
                                builder: (context, csm, child) =>
                                    StreamBuilder<Session>(
                                        stream: csm.sessionStream,
                                        builder: (context, snapshot) {
                                          return _InfoView(
                                            description: "Mitglieder",
                                            value: 20,
                                          );
                                        }),
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              Expanded(
                                  child: Material(
                                borderRadius: BorderRadius.circular(12),
                                color: _theme.colors.contrast,
                                clipBehavior: Clip.antiAlias,
                                child: Builder(builder: (context) {
                                  return InkWell(
                                    onTap: () {
                                      Scaffold.of(context).showSnackBar(SnackBar(
                                          content: Text(
                                              "Dieses Feature kommt im nächsten Update!")));
                                    },
                                    child: Container(
                                        height: 70,
                                        child: Center(
                                            child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "Zum Chat",
                                              style: _theme.textTheme
                                                  .textOnContrast.bodyText1
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            SizedBox(
                                              width: 6,
                                            ),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              size: 15,
                                              color:
                                                  _theme.colors.textOnContrast,
                                            )
                                          ],
                                        ))),
                                  );
                                }),
                              )),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Divider(),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        sliver: _CertifiedSessionMembers(),
                      ),
                      SliverToBoxAdapter(
                        child: Divider(),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        sliver: CampaignInfo<CertifiedSessionManager>(),
                      ),
                    ]),
              ),
              Positioned(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Material(
                    clipBehavior: Clip.antiAlias,
                    shape: CircleBorder(),
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: IconButton(
                          icon: Icon(Icons.arrow_downward),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                    ),
                  ),
                ),
                top: MediaQuery.of(context).padding.top,
                left: 0,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoView extends StatelessWidget {
  final String description;
  final int value;

  const _InfoView({Key key, this.description, this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return Container(
      height: 70,
      child: Center(
        child: Material(
          color: _theme.colors.dark,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text(
                  Numeral(value).value(),
                  style: _theme.textTheme.textOnDark.headline6,
                ),
                Text(
                  description,
                  style: _theme.textTheme.textOnDark.bodyText2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CertifiedSessionMembers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return SliverToBoxAdapter(
      child: Consumer<CertifiedSessionManager>(
        builder: (context, sm, child) => SizedBox(
            height: 150,
            child: CustomScrollView(
              scrollDirection: Axis.horizontal,
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 150,
                  ),
                ),
                StreamBuilder<List<SessionMember>>(
                    stream: sm.membersStream,
                    builder: (context, snapshot) {
                      List<SessionMember> members = snapshot.data ?? [];
                      if (members.isEmpty)
                        return SliverToBoxAdapter(
                          child: SizedBox(
                            width: 12,
                          ),
                        );
                      return SliverPadding(
                        padding: const EdgeInsets.only(left: 12),
                        sliver: SliverToBoxAdapter(
                          child: Center(
                              child: RotatedBox(
                                  quarterTurns: 3,
                                  child: Text(
                                    "Mitglieder",
                                    style: _theme.textTheme.dark.bodyText1,
                                  ))),
                        ),
                      );
                    }),
                StreamBuilder<List<SessionMember>>(
                    stream: sm.membersStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return SliverToBoxAdapter(
                          child: Center(
                              child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                      _theme.colors.dark),
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                Text("Lade Mitglieder...",
                                    style: _theme.textTheme.dark.bodyText1)
                              ],
                            ),
                          )),
                        );

                      List<SessionMember> members = snapshot.data ?? [];
                      return SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return Padding(
                            padding: EdgeInsets.only(
                                left: index <= members.length - 1 ? 12.0 : 0.0),
                            child: SessionMemberView<CertifiedSessionManager>(
                                member: members[index]),
                          );
                        }, childCount: members.length),
                      );
                    }),
              ],
            )),
      ),
    );
  }
}

class _SessionJoinButton extends StatefulWidget {
  _SessionJoinButton({Key key}) : super(key: key);

  @override
  __SessionJoinButtonState createState() => __SessionJoinButtonState();
}

class __SessionJoinButtonState extends State<_SessionJoinButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return Consumer<CertifiedSessionManager>(
      builder: (context, csm, child) => StreamBuilder<bool>(
          initialData: false,
          stream: csm.isInSession,
          builder: (context, snapshot) {
            Color color = snapshot.data
                ? _theme.colors.textOnDark
                : _theme.colors.textOnContrast;
            return RaisedButton(
              onPressed: () async {
                setState(() {
                  _loading = true;
                });
                if (snapshot.data)
                  await DatabaseService.leaveCertifiedSession(
                      csm.baseSession.id);
                else
                  await DatabaseService.joinCertifiedSession(
                      csm.baseSession.id);
                setState(() {
                  _loading = false;
                });
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              color:
                  snapshot.data ? _theme.colors.dark : _theme.colors.contrast,
              textColor: color,
              child: Row(
                children: [
                  _loading
                      ? Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.only(right: 12),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(color),
                          ))
                      : Container(),
                  snapshot.data ? Text("VERLASSEN") : Text("BEITRETEN"),
                ],
              ),
            );
          }),
    );
  }
}
