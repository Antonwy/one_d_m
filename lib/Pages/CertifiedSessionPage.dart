import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Components/SessionsFeed.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Numeral.dart';
import 'package:one_d_m/Helper/Provider/SessionManager.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/SessionMessage.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/SessionPage.dart';
import 'package:provider/provider.dart';

class CertifiedSessionPage extends StatefulWidget {
  Session session;

  CertifiedSessionPage({Key key, this.session}) : super(key: key);

  @override
  _CertifiedSessionPageState createState() => _CertifiedSessionPageState();
}

class _CertifiedSessionPageState extends State<CertifiedSessionPage> {
  ThemeManager _theme;

  Session session;

  PageController _pageController = PageController();
  ValueNotifier<double> _pagePosition = ValueNotifier(0);

  @override
  void initState() {
    session = widget.session;
    _pageController.addListener(() {
      _pagePosition.value = _pageController.page;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    UserManager _um = Provider.of<UserManager>(context, listen: false);
    return Provider<CertifiedSessionManager>(
      create: (context) => CertifiedSessionManager(
        session: session,
        uid: _um.uid,
      ),
      builder: (context, child) {
        return Scaffold(
          floatingActionButton: ValueListenableBuilder(
            valueListenable: _pagePosition,
            builder: (context, val, child) => Opacity(
              opacity: 1 - val,
              child: Transform.scale(
                scale: 1 - val,
                child: FloatingDonationButton(
                  session,
                ),
              ),
            ),
          ),
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: _theme.colors.dark),
            actions: [_CertifiedSessionPageIndicator(_pageController)],
          ),
          body: PageView(
              controller: _pageController,
              children: [_CertifiedSessionInfoPage(), _CertifiedSessionChat()]),
        );
      },
    );
  }
}

class _CertifiedSessionPageIndicator extends StatefulWidget {
  PageController _pageController;

  _CertifiedSessionPageIndicator(this._pageController);

  @override
  __CertifiedSessionPageIndicatorState createState() =>
      __CertifiedSessionPageIndicatorState();
}

class __CertifiedSessionPageIndicatorState
    extends State<_CertifiedSessionPageIndicator> {
  double _pageValue = 0;

  @override
  void initState() {
    widget._pageController.addListener(() {
      setState(() {
        _pageValue = widget._pageController.page;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: Container(
          width: 90,
          height: 45,
          child: Material(
            color: _theme.colors.contrast,
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Align(
                  alignment: AlignmentTween(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight)
                      .transform(_pageValue),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 9.5),
                    child: Container(
                      width: 35,
                      height: 30,
                      child: Material(
                        color: _theme.colors.dark,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _changePage(0);
                          },
                          child: Icon(
                            Icons.info,
                            size: 18,
                            color: ColorTween(
                                    begin: _theme.colors.contrast,
                                    end: _theme.colors.dark)
                                .transform(_pageValue),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _changePage(1);
                          },
                          child: Icon(
                            Icons.message,
                            size: 18,
                            color: ColorTween(
                                    begin: _theme.colors.dark,
                                    end: _theme.colors.contrast)
                                .transform(_pageValue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _changePage(int page) {
    widget._pageController.animateToPage(page,
        duration: Duration(milliseconds: 250),
        curve: Curves.fastLinearToSlowEaseIn);
  }
}

class _CertifiedSessionChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return Consumer<CertifiedSessionManager>(
      builder: (context, csm, child) => Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Divider(
                height: 1,
              )),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: StreamBuilder<List<SessionMessage>>(
                  stream: DatabaseService.getSessionMessages(csm.session.id),
                  builder: (context, snapshot) {
                    List<SessionMessage> messages = snapshot.data ?? [];
                    return messages.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 150,
                              ),
                              SvgPicture.asset("assets/images/no-news.svg",
                                  height: 150),
                              SizedBox(
                                height: 12,
                              ),
                              Text(
                                "Hier gibt es noch keine Nachrichten.",
                                style: _theme.textTheme.dark.bodyText1,
                              ),
                            ],
                          )
                        : ListView.separated(
                            itemCount: messages.length,
                            reverse: true,
                            separatorBuilder: (context, index) => SizedBox(
                                  height: 6,
                                ),
                            itemBuilder: (context, index) {
                              SessionMessage msg = messages[index];
                              return Padding(
                                padding: index == 0
                                    ? EdgeInsets.only(
                                        bottom: 92 +
                                            MediaQuery.of(context)
                                                .padding
                                                .bottom)
                                    : EdgeInsets.zero,
                                child: _SessionMessageView(msg),
                              );
                            });
                  }),
            ),
          ),
          _ChatTextField()
        ],
      ),
    );
  }
}

class _SessionMessageView extends StatelessWidget {
  final SessionMessage msg;

  const _SessionMessageView(this.msg);

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return Consumer<UserManager>(
      builder: (context, um, child) {
        bool isOwnMessage = um.uid == msg.fromUid;
        return isOwnMessage
            ? Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Material(
                            color: _theme.colors.dark,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                                bottomLeft: Radius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(msg.message,
                                  style: _theme.textTheme.textOnDark.bodyText1),
                            )),
                      ),
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    FutureBuilder<User>(
                        future: DatabaseService.getUser(msg.fromUid),
                        builder: (context, snapshot) {
                          return Avatar(snapshot.data?.imgUrl, radius: 16);
                        }),
                  ],
                ),
              )
            : Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FutureBuilder<User>(
                        future: DatabaseService.getUser(msg.fromUid),
                        builder: (context, snapshot) {
                          return Avatar(snapshot.data?.imgUrl, radius: 16);
                        }),
                    SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Material(
                            color: _theme.colors.contrast,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                                bottomRight: Radius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(msg.message,
                                  style: _theme
                                      .textTheme.textOnContrast.bodyText1),
                            )),
                      ),
                    ),
                  ],
                ),
              );
      },
    );
  }
}

class _ChatTextField extends StatelessWidget {
  TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 80 + MediaQuery.of(context).padding.bottom,
        width: double.infinity,
        child: Material(
          color: _theme.colors.contrast,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 12, 12, 0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (text) => _sendMessage(context),
                      decoration: InputDecoration.collapsed(
                          hintText: "Schreibe etwas..."),
                    ),
                  ),
                  Consumer2<CertifiedSessionManager, UserManager>(
                    builder: (context, csm, um, child) => IconButton(
                        icon: Icon(
                          Icons.send,
                          color: _theme.colors.textOnContrast,
                        ),
                        onPressed: () => _sendMessage(context)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendMessage(BuildContext context) async {
    UserManager um = Provider.of<UserManager>(context, listen: false);
    CertifiedSessionManager csm =
        Provider.of<CertifiedSessionManager>(context, listen: false);
    if (_textController.text.isEmpty) return;
    SessionMessage msg = SessionMessage(
        fromUid: um.uid, message: _textController.text, toSid: csm.session.id);
    await DatabaseService.sendMessageToSession(msg);
    _textController.clear();
  }
}

class _CertifiedSessionInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return Consumer<CertifiedSessionManager>(
      builder: (context, csm, child) => CustomScrollView(slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverToBoxAdapter(
            child: Container(
              height: 220,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Material(
                      elevation: 10,
                      borderRadius: BorderRadius.circular(6),
                      clipBehavior: Clip.antiAlias,
                      child: CachedNetworkImage(
                        imageUrl: csm.session.imgUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12.0, 6, 12, 6),
          sliver: SliverToBoxAdapter(
              child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      csm.session.name,
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    StreamBuilder(
                      stream:
                          DatabaseService.getUserStream(csm.session.creatorId),
                      builder: (context, AsyncSnapshot<User> snapshot) {
                        return Text(
                          'by ${snapshot.data?.name}',
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: _SessionJoinButton(),
              )
            ],
          )),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12.0, 6, 12, 6),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                StreamBuilder<Session>(
                    stream: csm.sessionStream,
                    builder: (context, snapshot) {
                      return Container(
                        width: 90,
                        child: _InfoView(
                          description: "DV",
                          value: snapshot.data?.currentAmount ??
                              csm.session.currentAmount ??
                              0,
                        ),
                      );
                    }),
                SizedBox(
                  width: 8,
                ),
                StreamBuilder<Session>(
                    stream: csm.sessionStream,
                    builder: (context, snapshot) {
                      return Expanded(
                        child: _InfoView(
                            imageUrl: snapshot.data?.campaignImgUrl ??
                                csm.session.campaignImgUrl,
                            description: snapshot.data?.campaignName ??
                                csm.session.campaignName),
                      );
                    }),
                SizedBox(
                  width: 8,
                ),
                StreamBuilder<Session>(
                    stream: csm.sessionStream,
                    builder: (context, snapshot) {
                      return Container(
                        width: 90,
                        child: _InfoView(
                          description: "Mitglieder",
                          value: snapshot.data?.memberCount ??
                              csm.session.memberCount,
                        ),
                      );
                    }),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Donators',
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          sliver: _CertifiedSessionMembers(),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 100,
          ),
        )
      ]),
    );
  }
}

class _InfoView extends StatelessWidget {
  final String description;
  final String imageUrl;
  final num value;

  const _InfoView({Key key, this.description, this.value, this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return Material(
      color: imageUrl != null ? ColorTheme.wildGreen : _theme.colors.dark,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            imageUrl != null
                ? Container(
                    height: 60,
                    width: 50,
                    child: Material(
                        clipBehavior: Clip.antiAlias,
                        shape: CircleBorder(),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                        )),
                  )
                : Container(
                    height: 60,
                    width: 50,
                    child: Center(
                      child: AutoSizeText(
                        Numeral(value).value(),
                        maxLines: 1,
                        style: _theme.textTheme.textOnDark.headline5
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
            SizedBox(
              height: imageUrl != null ? 6 : 0,
            ),
            AutoSizeText(
              description,
              maxLines: 1,
              style: imageUrl != null
                  ? _theme.textTheme.textOnDark.bodyText2
                      .copyWith(fontWeight: FontWeight.bold)
                  : _theme.textTheme.textOnDark.bodyText2,
              textAlign: TextAlign.center,
            ),
          ],
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
                    height: 130,
                  ),
                ),
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
                      members.sort((a, b) =>
                          b.donationAmount.compareTo(a.donationAmount));
                      return SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return Padding(
                            padding: EdgeInsets.only(
                                left: index <= members.length - 1 ? 12.0 : 0.0),
                            child: SessionMemberView<CertifiedSessionManager>(
                                member: members[index], showTargetAmount: true),
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
            return MaterialButton(
              height: 50,
              onPressed: () async {
                setState(() {
                  _loading = true;
                });
                if (snapshot.data)
                  await DatabaseService.leaveCertifiedSession(
                          csm.baseSession.id)
                      .then((value) {
                    setState(() {
                      _loading = false;
                    });
                  });
                else
                  await DatabaseService.joinCertifiedSession(csm.baseSession.id)
                      .then((value) {
                    setState(() {
                      _loading = false;
                    });
                  });
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              color: snapshot.data ? _theme.colors.dark : _theme.colors.dark,
              textColor: color,
              child: _loading
                  ? Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(right: 12),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(_theme.colors.light),
                      ))
                  : Text(
                      snapshot.data ? "VERLASSEN" : 'BEITRETEN',
                      style: Theme.of(context)
                          .accentTextTheme
                          .button
                          .copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
            );
          }),
    );
  }
}
