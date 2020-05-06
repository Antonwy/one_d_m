import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/CampaignList.dart';
import 'package:one_d_m/Components/CategoriesList.dart';
import 'package:one_d_m/Components/SearchBar.dart';
import 'package:one_d_m/Components/UserAvatar.dart';
import 'package:one_d_m/Helper/CampaignsManager.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Pages/FindFriendsPage.dart';
import 'package:provider/provider.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with AutomaticKeepAliveClientMixin {
  TextTheme textTheme;
  int _categoryId = 4;

  Stream<List<User>> _userStream;

  @override
  void initState() {
    _userStream = DatabaseService.getUsersStream();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    textTheme = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: Colors.white,
          centerTitle: false,
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: Size(0, 80),
            child: Container(),
          ),
          flexibleSpace: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Text("Entdecken", style: textTheme.title),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Container(
                        height: 40,
                        child: Material(
                          color: ColorTheme.blue,
                          borderRadius: BorderRadius.circular(20),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (c) => FindFriendsPage()));
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "Freunde finden",
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 18,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: SearchBar(),
                ),
              ],
            ),
          ),
        ),
        // StreamBuilder<List<User>>(
        //     stream: _userStream,
        //     builder: (context, snapshot) {
        //       if (!snapshot.hasData) return SliverToBoxAdapter();
        //       if (snapshot.data.isEmpty) return SliverToBoxAdapter();
        //       return SliverToBoxAdapter(
        //         child: Container(
        //           height: 110,
        //           child: UserAvatarList(snapshot.data),
        //         ),
        //       );
        //     }),
        SliverToBoxAdapter(
          child: Container(
              height: 115,
              margin: EdgeInsets.symmetric(vertical: 18),
              child: CategoriesList((catId) {
                setState(() {
                  _categoryId = catId;
                });
              })),
        ),
        Consumer<CampaignsManager>(builder: (context, cm, child) {
          return CampaignList(
            campaigns: cm.getCampaignFromCategoryId(_categoryId),
          );
        })
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class UserAvatarList extends StatelessWidget {
  final List<User> userList;

  UserAvatarList(this.userList);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: userList.length + 1,
      separatorBuilder: (context, index) => SizedBox(
        width: 10,
      ),
      itemBuilder: (context, index) => Padding(
        padding: index == 0
            ? const EdgeInsets.only(left: 18.0)
            : index == userList.length
                ? const EdgeInsets.only(right: 18.0)
                : const EdgeInsets.all(0),
        child: index == 0
            ? _getAddFriendsButton()
            : UserAvatar(userList[index - 1]),
      ),
    );
  }

  _getAddFriendsButton() {
    return Container(
      height: 110,
      width: 70,
      child: Column(
        children: <Widget>[
          Container(
            width: 70,
            height: 70,
            child: OpenContainer(
              tappable: true,
              closedColor: ColorTheme.avatar,
              closedShape: CircleBorder(),
              openBuilder: (context, close) => FindFriendsPage(),
              closedBuilder: (context, open) => Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "Freunde finden",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
