import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/Components/DonationWidget.dart';
import 'package:one_d_m/Components/UserButton.dart';
import 'package:one_d_m/Components/UserFollowButton.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Feed.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Helper/margin.dart';
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
          return SliverList(
              delegate: SliverChildBuilderDelegate((context, i) {
            FeedObject _fo = snapshot.data[i];
            return _fo.buildWidget(context,
                highlighted: widget.feedDoc.unseenObjects.contains(_fo.id));
          }, childCount: snapshot.data?.length ?? 0));
        });
  }
}
