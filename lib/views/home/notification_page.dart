import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/database_service.dart';
import 'package:one_d_m/models/feed.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  final FeedDoc feedDoc;

  const NotificationPage(this.feedDoc);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    DatabaseService.unseeFeed(context.read<UserManager>().uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.appBg,
      body: _buildBody(),
    );
  }

  Widget _buildBody() => CustomScrollView(
        slivers: [_buildAppBar(), _buildFeed()],
      );

  Widget _buildAppBar() => SliverAppBar(
        pinned: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Text('Neuigkeiten',
            style: TextStyle(color: ThemeManager.of(context).colors.dark)),
        brightness: Brightness.dark,
        backgroundColor: ColorTheme.appBg,
        iconTheme: IconThemeData(color: ColorTheme.blue),
      );

  Widget _buildFeed() {
    print("BUILD FEED");
    return StreamBuilder<List<FeedObject>>(
        initialData: [],
        stream: DatabaseService.getFeed(context.read<UserManager>().uid),
        builder: (context, snapshot) {
          if (snapshot.data.isEmpty)
            return SliverToBoxAdapter(
              child: Column(
                children: [
                  YMargin(24),
                  SvgPicture.asset(
                    "assets/images/no-news.svg",
                    height: 200,
                  ),
                  YMargin(12),
                  Text("Noch keine Neuigkeiten!")
                ],
              ),
            );
          return SliverList(
              delegate: SliverChildBuilderDelegate((context, i) {
            FeedObject _fo = snapshot.data[i];
            return _fo.buildWidget(context,
                highlighted: widget.feedDoc.unseenObjects.contains(_fo.id));
          }, childCount: snapshot.data?.length ?? 0));
        });
  }
}
