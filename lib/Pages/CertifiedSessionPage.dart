import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/SessionsFeed.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/Provider/SessionManager.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/UserManager.dart';
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
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(
                              widget.session.imgUrl))),
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 18),
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
                                Consumer<CertifiedSessionManager>(
                                  builder: (context, csm, child) =>
                                      StreamBuilder<bool>(
                                          initialData: false,
                                          stream: csm.isInSession,
                                          builder: (context, snapshot) {
                                            return RaisedButton(
                                              onPressed: () {},
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6)),
                                              color: _theme.colors.contrast,
                                              textColor:
                                                  _theme.colors.textOnContrast,
                                              child: snapshot.data
                                                  ? Text("VERLASSEN")
                                                  : Text("BEITRETEN"),
                                            );
                                          }),
                                ),
                              ],
                            ),
                          )),
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
