import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Components/CustomOpenContainer.dart';
import 'package:one_d_m/Components/InfoFeed.dart';
import 'package:one_d_m/Components/NativeAd.dart';
import 'package:one_d_m/Components/NewsPost.dart';
import 'package:one_d_m/Components/SessionsFeed.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/Numeral.dart';
import 'package:one_d_m/Helper/Provider/SessionManager.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/SessionMessage.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:one_d_m/Pages/NewCampaignPage.dart';
import 'package:one_d_m/Pages/SessionPage.dart';
import 'package:one_d_m/Pages/create_post.dart';
import 'package:one_d_m/utils/video/video_widget.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CertifiedSessionPage extends StatefulWidget {
  Session session;
  final ScrollController scrollController;

  CertifiedSessionPage({Key key, this.session, this.scrollController})
      : super(key: key);

  @override
  _CertifiedSessionPageState createState() => _CertifiedSessionPageState();
}

class _CertifiedSessionPageState extends State<CertifiedSessionPage> {
  ThemeManager _theme;

  Session session;

  PageController _pageController = PageController();
  ValueNotifier<double> _pagePosition = ValueNotifier(0);

  ScrollController _scrollController;
  ValueNotifier _scrollOffset;

  ImageProvider _sessionImage;

  @override
  void initState() {
    _scrollController = widget.scrollController ?? ScrollController();

    _scrollOffset = ValueNotifier(0);

    _scrollController.addListener(() {
      _scrollOffset.value = _scrollController.offset;
    });

    session = widget.session;
    _pageController.addListener(() {
      _pagePosition.value = _pageController.page;
    });

    _sessionImage = CachedNetworkImageProvider(widget.session.imgUrl ?? '');

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollOffset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    UserManager _um = Provider.of<UserManager>(context, listen: false);
    return Provider<CertifiedSessionManager>(
      create: (context) =>
          CertifiedSessionManager(session: session, uid: _um.uid),
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
                  color: session.primaryColor,
                ),
              ),
            ),
          ),
          backgroundColor: ColorTheme.appBg,
          appBar: AppBar(
            backgroundColor: ColorTheme.appBg,
            elevation: 0,
            titleSpacing: 0,
            iconTheme: IconThemeData(color: _theme.colors.dark),

            ///removed chat feature for now
            // actions: [_CertifiedSessionPageIndicator(_pageController)],
          ),
          body: _CertifiedSessionInfoPage(
            controller: _scrollController,
            sessionId: widget.session.id,
            image: _sessionImage,
          ),

          ///removed chat feature for now

          // body: PageView(
          //     controller: _pageController,
          //     children: [_CertifiedSessionInfoPage(), _CertifiedSessionChat()]),
        );
      },
    );
  }
}

class _CertifiedSessionPageIndicator extends StatefulWidget {
  PageController _pageController;
  final String sessionId;

  _CertifiedSessionPageIndicator(this._pageController, this.sessionId);

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
            borderRadius: BorderRadius.circular(Constants.radius),
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

class _CertifiedSessionInfoPage extends StatefulWidget {
  ScrollController controller;
  final String sessionId;
  ImageProvider image;

  _CertifiedSessionInfoPage(
      {Key key, this.controller, this.sessionId, this.image})
      : super(key: key);

  @override
  __CertifiedSessionInfoPageState createState() =>
      __CertifiedSessionInfoPageState();
}

class __CertifiedSessionInfoPageState extends State<_CertifiedSessionInfoPage> {
  bool isCreator = false;
  bool _isInView = false;

  @override
  void initState() {
    widget.controller = ScrollController()..addListener(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return Consumer<CertifiedSessionManager>(
      builder: (context, csm, child) =>
          CustomScrollView(controller: widget.controller, slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          sliver: SliverToBoxAdapter(
            child: VisibilityDetector(
              key: Key(csm.session.id),
              onVisibilityChanged: (VisibilityInfo info) {
                var visiblePercentage = info.visibleFraction * 100;
                if (mounted) {
                  if (visiblePercentage == 100) {
                    setState(() {
                      _isInView = true;
                    });
                  } else {
                    setState(() {
                      _isInView = false;
                    });
                  }
                }
              },
              child: Material(
                  elevation: 10,
                  borderRadius: BorderRadius.circular(6),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: _CertifiedSessionTitle(
                    isInView: _isInView,
                    image: widget.image,
                  )),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12.0, 4, 12, 6),
          sliver: SliverToBoxAdapter(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AutoSizeText(
                      csm.session.name,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.headline6.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _theme.colors.dark),
                    ),
                    csm.session.creatorId?.isNotEmpty ?? false
                        ? StreamBuilder(
                            stream: DatabaseService.getUserStream(
                                csm.session.creatorId),
                            builder: (context, AsyncSnapshot<User> snapshot) {
                              return RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(text: 'by '),
                                    TextSpan(
                                        text:
                                            '${snapshot.data?.name ?? 'Laden...'}',
                                        style: _theme.textTheme.dark.bodyText1
                                            .copyWith(
                                                decoration:
                                                    TextDecoration.underline,
                                                fontWeight: FontWeight.w700)),
                                  ],
                                  style: _theme.textTheme.dark.bodyText1
                                      .copyWith(
                                          color: _theme.colors.dark
                                              .withOpacity(.54)),
                                ),
                              );
                            },
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
              XMargin(12),
              Expanded(
                flex: 3,
                child: csm.session.creatorId?.isNotEmpty ?? true
                    ? Consumer<UserManager>(
                        builder: (context, um, child) =>
                            um.uid == csm.session.creatorId
                                ? CreatePostButton()
                                : _SessionJoinButton())
                    : _SessionJoinButton(),
              )
            ],
          )),
        ),
        SliverToBoxAdapter(child: _buildSessionGoal(csm, _theme)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
          sliver: SliverToBoxAdapter(
            child: Consumer<CertifiedSessionManager>(
              builder: (context, sm, child) => StreamBuilder(
                  stream: sm.membersStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return SizedBox.shrink();
                    List<SessionMember> members = snapshot.data ?? [];
                    if (members.isEmpty) return SizedBox.shrink();
                    return Text(
                      'Unterstützer',
                      style: _theme.textTheme.dark.headline6,
                    );
                  }),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(top: 4.0),
          sliver: _CertifiedSessionMembers(
            sessionId: widget.sessionId,
          ),
        ),
        SliverToBoxAdapter(
          child: const YMargin(10),
        ),
        _buildPostFeed(),
        SliverToBoxAdapter(
          child: const YMargin(100),
        ),
      ]),
    );
  }

  Widget _buildSessionGoal(CertifiedSessionManager csm, ThemeManager _theme) {
    return StreamBuilder<Session>(
        stream: csm.sessionStream,
        builder: (context, snapshot) {
          Session session = snapshot.data;
          return (session?.donationGoal ?? 0) > 0 &&
                  session?.donationUnit != null &&
                  session?.donationUnitEffect != null
              ? StreamBuilder<Campaign>(
                  stream: csm.campaign,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return SizedBox.shrink();
                    Campaign campaign = snapshot.data;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Material(
                            color: session.secondaryColor,
                            borderRadius:
                                BorderRadius.circular(Constants.radius),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                      child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                  text:
                                                      "${Numeral(session.donationGoalCurrent).value()} "),
                                              if (campaign.unitSmiley != null &&
                                                  campaign
                                                      .unitSmiley.isNotEmpty)
                                                TextSpan(
                                                    text:
                                                        "${campaign.unitSmiley}",
                                                    style: TextStyle(
                                                        fontSize: 38,
                                                        fontWeight:
                                                            FontWeight.w300))
                                              else
                                                TextSpan(
                                                    text:
                                                        "${campaign.unit ?? "DV"}",
                                                    style: TextStyle(
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.w300))
                                            ],
                                            style: _theme
                                                .textTheme.light.headline5
                                                .copyWith(
                                                    fontSize: 38,
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ),
                                        YMargin(8),
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              border: Border.all(
                                                  color: _theme.colors.light)),
                                          child: Material(
                                            color: Colors.transparent,
                                            clipBehavior: Clip.antiAlias,
                                            borderRadius:
                                                BorderRadius.circular(24),
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            NewCampaignPage(
                                                                campaign)));
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4.0,
                                                        horizontal: 12),
                                                child: Text(
                                                    "${campaign?.name ?? ""}",
                                                    style: _theme.textTheme
                                                        .light.bodyText1),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )),
                                  YMargin(6),
                                  Container(
                                      width: double.infinity,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6.0),
                                        child: PercentLine(
                                          percent: session.donationGoalCurrent /
                                              session.donationGoal,
                                          height: 10.0,
                                          color: _theme.colors.light,
                                        ),
                                      )),
                                  YMargin(6.0),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${_formatPercent(session)}% erreicht",
                                        style: _theme.textTheme.light.bodyText1,
                                      ),
                                      RichText(
                                          text: TextSpan(
                                              style: _theme
                                                  .textTheme.light.bodyText1
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w400),
                                              children: [
                                            TextSpan(
                                              text: "Ziel: ",
                                            ),
                                            TextSpan(
                                                text:
                                                    "${session.donationGoal} ",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            TextSpan(
                                                text:
                                                    "${campaign.unitSmiley ?? campaign.unit ?? "DV"}"),
                                          ])),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  })
              : SizedBox.shrink();
        });
  }

  String _formatPercent(Session session) {
    double percentValue =
        (session.donationGoalCurrent / session.donationGoal) * 100;

    if (percentValue < 1) return percentValue.toStringAsFixed(2);
    if ((percentValue % 1) == 0) return percentValue.toInt().toString();

    return percentValue.toStringAsFixed(1);
  }

  Widget _buildPostFeed() => Consumer<CertifiedSessionManager>(
      builder: (context, sm, child) => StreamBuilder<List<News>>(
            stream: DatabaseService.getPostBySessionId(sm.session.id),
            builder: (_, snapshot) {
              if (snapshot.hasData) {
                List<News> posts = snapshot.data;
                if (posts.isNotEmpty) {
                  posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                  return SliverList(
                    delegate:
                        SliverChildListDelegate(_getNewsWidget(context, posts)),
                  );
                } else {
                  return SliverToBoxAdapter(child: SizedBox.shrink());
                }
              } else {
                return SliverToBoxAdapter(
                    child: Center(
                  child: CircularProgressIndicator(),
                ));
              }
            },
          ));

  List<Widget> _getNewsWidget(BuildContext context, List<News> news) {
    List<Widget> widgets = [];
    int adRate = Constants.AD_NEWS_RATE;
    int rateCount = 0;
    bool _playVideo = false;
    Widget newsTitle = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: Text(
        'News',
        style: Theme.of(context)
            .textTheme
            .headline6
            .copyWith(fontWeight: FontWeight.bold),
      ),
    );
    widgets.add(newsTitle);
    for (News n in news) {
      rateCount++;

      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: NewsPost(
          n,
          withHeader: false,
          isInView: false,
        ),
      ));

      if (rateCount >= adRate) {
        widgets.add(Padding(
          padding: const EdgeInsets.all(10.0),
          child: NewsNativeAd(
            id: Constants.ADMOB_SESSION_ID,
          ),
        ));
        rateCount = 0;
      }
    }

    return widgets;
  }
}

class _InfoView extends StatelessWidget {
  final String description;
  final String imageUrl;
  final num value;
  final Color color;

  const _InfoView(
      {Key key, this.description, this.value, this.imageUrl, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return Container(
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Constants.radius),
        color: color,
      ),
      child: Padding(
        padding: EdgeInsets.all(imageUrl != null ? 2.0 : 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            imageUrl != null
                ? Container(
                    height: 44,
                    width: 44,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      imageBuilder: (_, imgProvider) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              width: 2, color: _theme.colors.textOnDark),
                          image: DecorationImage(
                            image: imgProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ))
                : AutoSizeText(
                    Numeral(value).value(),
                    maxLines: 1,
                    style: _theme.textTheme.textOnDark.headline5
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
            SizedBox(
              height: imageUrl != null ? 2 : 0,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: AutoSizeText(
                description,
                maxLines: imageUrl != null ? 2 : 1,
                softWrap: true,
                style: imageUrl != null
                    ? _theme.textTheme.textOnDark.bodyText2.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      )
                    : _theme.textTheme.textOnDark.bodyText2,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CertifiedSessionTitle extends StatefulWidget {
  final bool isInView;
  final ImageProvider image;

  const _CertifiedSessionTitle({Key key, this.isInView, this.image})
      : super(key: key);

  @override
  __CertifiedSessionTitleState createState() => __CertifiedSessionTitleState();
}

class __CertifiedSessionTitleState extends State<_CertifiedSessionTitle> {
  bool _muted = true;

  void _toggleMuted() {
    setState(() {
      _muted = !_muted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CertifiedSessionManager>(
      builder: (context, csm, child) => csm.session?.videoUrl == null
          ? Image(
              height: 220,
              image: widget.image,
              fit: BoxFit.cover,
            )
          : Stack(
              children: [
                VideoWidget(
                  url: csm.session.videoUrl,
                  play: widget.isInView,
                  image: widget.image,
                  muted: _muted,
                  toggleMuted: _toggleMuted,
                ),
                Positioned(
                    bottom: 12,
                    left: 12,
                    child: MuteButton(
                      muted: _muted,
                      toggle: _toggleMuted,
                    ))
              ],
            ),
    );
  }
}

class _CertifiedSessionMembers extends StatefulWidget {
  final String sessionId;

  const _CertifiedSessionMembers({Key key, this.sessionId}) : super(key: key);

  @override
  __CertifiedSessionMembersState createState() =>
      __CertifiedSessionMembersState();
}

class __CertifiedSessionMembersState extends State<_CertifiedSessionMembers> {
  List<SessionMember> members = [];
  List<SessionMember> sessionMembers = [];
  List<SessionMember> allMembers = [];
  List<SessionMember> uniqueAllMembers = [];
  List<String> userIds = [];
  List<String> uniqueId = [];

  @override
  void initState() {
    ///get donated members
    DatabaseService.getDonationsFromSession(widget.sessionId).listen((d) {
      members.clear();
      sessionMembers.clear();
      userIds.clear();
      uniqueId.clear();
      uniqueAllMembers.clear();
      allMembers.clear();

      d.forEach((don) {
        members
            .add(SessionMember(userId: don.userId, donationAmount: don.amount));
      });

      DatabaseService.getSessionMembers(widget.sessionId).listen((m) {
        sessionMembers.clear();
        userIds.clear();
        uniqueId.clear();
        uniqueAllMembers.clear();
        allMembers.clear();
        allMembers = [...m, ...members];

        allMembers.sort((a, b) => b.donationAmount.compareTo(a.donationAmount));
        //remove duplicates
        allMembers.forEach((element) {
          userIds.add(element.userId);
        });
        uniqueId = userIds.toSet().toList();

        uniqueId.forEach((id) {
          SessionMember sm =
              allMembers.firstWhere((element) => element.userId == id);
          uniqueAllMembers.add(sm);
        });

        setState(() {});
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Consumer<CertifiedSessionManager>(
        builder: (context, sm, child) => SizedBox(
            height: 155,
            child: CustomScrollView(
              scrollDirection: Axis.horizontal,
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 155,
                  ),
                ),
                uniqueAllMembers.isNotEmpty
                    ? SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return Padding(
                            padding: EdgeInsets.only(
                                left: index == 0 ? 6.0 : 0.0,
                                right: index == uniqueAllMembers.length - 1
                                    ? 6.0
                                    : 0.0),
                            child: SessionMemberView<CertifiedSessionManager>(
                              member: uniqueAllMembers[index],
                              showTargetAmount: true,
                              color: sm.session.primaryColor,
                              avatarColor: Colors.white,
                              avatarBackColor: sm.session.secondaryColor,
                            ),
                          );
                        }, childCount: uniqueAllMembers.length),
                      )
                    : SliverToBoxAdapter(child: SizedBox.shrink())
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
            return RaisedButton(
              color: snapshot.data
                  ? csm.session.primaryColor
                  : csm.session.secondaryColor,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              child: _loading
                  ? Container(
                      width: 18,
                      height: 18,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 3.0,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      ))
                  : AutoSizeText(
                      snapshot.data ? "VERLASSEN" : 'BEITRETEN',
                      maxLines: 1,
                    ),
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
            );
          }),
    );
  }
}

class CreatePostButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return Consumer<CertifiedSessionManager>(
      builder: (context, csm, child) => StreamBuilder<bool>(
          initialData: false,
          stream: csm.isInSession,
          builder: (context, snapshot) {
            return CustomOpenContainer(
              closedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              closedElevation: 0,
              openBuilder: (context, close, scrollController) =>
                  CreatePostScreen(
                isSession: true,
                session: csm.session,
                controller: scrollController,
              ),
              closedColor: Colors.transparent,
              closedBuilder: (context, open) => RaisedButton(
                  color: csm.session.primaryColor,
                  textColor: _theme.colors.textOnDark,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  child: AutoSizeText("Post erstellen", maxLines: 1),
                  onPressed: open),
            );
          }),
    );
  }
}
