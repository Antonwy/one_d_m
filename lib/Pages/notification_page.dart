import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/DonationWidget.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/margin.dart';

class NotificationPage extends StatefulWidget {
  final User user;
  final ScrollController scrollController;

  const NotificationPage({Key key, this.scrollController, this.user})
      : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.whiteBlue,
      body: _buildBody(),
    );
  }

  Widget _buildBody() => CustomScrollView(
        controller: widget.scrollController,
        slivers: [
          _buildAppBar(),
          const SliverToBoxAdapter(
            child: YMargin(20),
          ),
          _buildFollowers()
        ],
      );

  Widget _buildAppBar() => SliverAppBar(
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Neuigkeiten',
          style: Theme.of(context)
              .textTheme
              .headline6
              .copyWith(fontWeight: FontWeight.w700),
        ),
        automaticallyImplyLeading: false,
        brightness: Brightness.dark,
        backgroundColor: ColorTheme.whiteBlue,
        iconTheme: IconThemeData(color: ColorTheme.blue),
        elevation: 0,
      );

  Widget _buildFollowers() => StreamBuilder(
        stream: DatabaseService.getFollowedUsersStream(widget.user.id),
        builder: (_, snapshot) {
          if (!snapshot.hasData)
            return SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator(),)
            );
          List<String> followers = snapshot.data;
          if (followers.isEmpty)
            return SliverToBoxAdapter(
              child: SizedBox.shrink(),
            );

          return SliverList(
              delegate: SliverChildListDelegate(_buildUsers(followers)));
        },
      );

  List<Widget> _buildUsers(List<String> followers) {
    List<Widget> widgets = [];
    for (String s in followers) {
      widgets.add(FutureBuilder(
          future: DatabaseService.getUser(s),
          builder: (_, snapshot) {
            if (!snapshot.hasData) return SizedBox.shrink();
            User u = snapshot.data;
            return ListTile(
              contentPadding: EdgeInsets.only(top: 8.0, left: 12.0,right: 12.0),
              leading: _buildUserAvatar(
                  u?.thumbnailUrl ?? u?.imgUrl, !snapshot.hasData),
              title: _buildTitle(u),
              trailing: _buildFollowButton(u.id),
            );
          }));
    }
    return widgets;
  }

  Widget _buildUserAvatar(String url, bool loading) => Padding(
        padding: const EdgeInsets.all(4.0),
        child: RoundedAvatar(
          url,
          height: 42,
          loading: loading,
        ),
      );

  Widget _buildTitle(User user) => StreamBuilder(
        initialData: false,
        stream: DatabaseService.getFollowStream(widget.user.id, user.id),
        builder: (_, snapshot) {
          bool _followed = snapshot.data;
          return Row(
            children: [
              AutoSizeText(
                user?.name ?? '',
                style: Theme.of(context).textTheme.headline6,
              ),
              _followed
                  ? AutoSizeText(
                      ' folgt dir jetzt',
                      style: Theme.of(context).textTheme.subtitle1,
                    )
                  : SizedBox.shrink(),
            ],
          );
        },
      );

  Widget _buildFollowButton(
    String uid,
  ) =>
      StreamBuilder<bool>(
          initialData: true,
          stream: DatabaseService.getFollowStream(widget.user.id, uid),
          builder: (context, snapshot) {
            bool _followed = snapshot.data;
            return !_followed
                ? RaisedButton(
                    color: ThemeManager.of(context).colors.dark,
                    textColor: ThemeManager.of(context).colors.textOnDark,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    child: AutoSizeText(
                      "Folgen",
                      maxLines: 1,
                    ),
                    onPressed: () => _followUser(uid))
                : SizedBox.shrink();
          });

  Future<void> _followUser(
    String uid,
  ) async {
    await DatabaseService.createFollow(widget.user.id, uid);
  }
}
