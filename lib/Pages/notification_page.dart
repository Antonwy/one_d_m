import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/DonationWidget.dart';
import 'package:one_d_m/Components/UserButton.dart';
import 'package:one_d_m/Components/UserFollowButton.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  final ScrollController scrollController;

  const NotificationPage({Key key, this.scrollController}) : super(key: key);

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
      backgroundColor: ColorTheme.appBg,
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
        title: Text('Neuigkeiten',
            style: TextStyle(color: ThemeManager.of(context).colors.dark)),
        automaticallyImplyLeading: false,
        brightness: Brightness.dark,
        backgroundColor: ColorTheme.whiteBlue,
        iconTheme: IconThemeData(color: ColorTheme.blue),
        elevation: 0,
      );

  Widget _buildFollowers() => Consumer<UserManager>(
        builder: (context, um, child) => StreamBuilder(
          stream: DatabaseService.getFollowedUsersStream(um.uid),
          builder: (_, snapshot) {
            if (!snapshot.hasData)
              return SliverToBoxAdapter(
                  child: Center(
                child: CircularProgressIndicator(),
              ));
            List<String> followers = snapshot.data;
            if (followers.isEmpty)
              return SliverToBoxAdapter(
                child: SizedBox.shrink(),
              );

            return SliverList(
                delegate: SliverChildListDelegate(_buildUsers(followers)));
          },
        ),
      );

  List<Widget> _buildUsers(List<String> followers) => followers
      .map((id) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
            child: UserButton(
              id,
              elevation: 0,
              withAddButton: true,
              additionalText: "folgt dir jetzt",
            ),
          ))
      .toList();

  Widget _buildUserAvatar(String url, bool loading) => Padding(
        padding: const EdgeInsets.all(4.0),
        child: RoundedAvatar(
          url,
          loading: loading,
        ),
      );

  Widget _buildTitle(User user) => AutoSizeText.rich(
        TextSpan(children: [
          TextSpan(
              text: user?.name ?? '',
              style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: ' folgt dir jetzt'),
        ]),
        style: TextStyle(fontSize: 14),
      );

  Widget _buildFollowButton(
    String uid,
  ) =>
      UserFollowButton(
        followerId: uid,
      );

  Future<void> _followUser(
    String uid,
  ) async {
    await DatabaseService.createFollow(context.read<UserManager>().uid, uid);
  }
}
