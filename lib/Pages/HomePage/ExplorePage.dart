import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/AnimatedFutureBuilder.dart';
import 'package:one_d_m/Components/CampaignHeader.dart';
import 'package:one_d_m/Components/SearchBar.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Pages/UserPage.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  TextTheme textTheme;

  List<Campaign> campaigns;

  String searchQuery = "";

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
            preferredSize: Size(0, 200),
            child: Container(),
          ),
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Entdecken", style: textTheme.title),
                  SizedBox(
                    height: 10,
                  ),
                  SearchBar(onChanged: (String text) {
                    setState(() {
                      searchQuery = text;
                    });
                  }),
                  SizedBox(height: 20),
                  AnimatedFutureBuilder<List<User>>(
                      future: DatabaseService().getUsers(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data.isEmpty) return Container();
                          return Container(
                            height: 85,
                            child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: _buildUserAvatars(snapshot.data)),
                          );
                        }
                        return Container();
                      })
                ],
              ),
            ),
          ),
        ),
        StreamBuilder<List<Campaign>>(
          stream: DatabaseService().getCampaignFromQuery(searchQuery),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              this.campaigns = snapshot.data;
              return SliverList(
                delegate: SliverChildListDelegate(_buildChildren(context)),
              );
            }
            return SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
      ],
    );
  }

  List<Widget> _buildUserAvatars(List<User> users) {
    List<Widget> list = [];

    for (User user in users) {
      list.add(Column(
        children: <Widget>[
          Container(
            width: 60,
            height: 60,
            child: Material(
              color: Colors.grey[300],
              shape: CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (c) => UserPage(user)));
                  },
                  child: user.imgUrl == null
                      ? Icon(Icons.person)
                      : CachedNetworkImage(
                          imageUrl: user.imgUrl,
                          fit: BoxFit.cover,
                        )),
            ),
          ),
          SizedBox(height: 5),
          Text(user.firstname)
        ],
      ));
      list.add(SizedBox(
        width: 10,
      ));
    }

    return list;
  }

  List<Widget> _buildChildren(BuildContext context) {
    List<Widget> list = [];

    for (Campaign c in campaigns) {
      list.add(CampaignHeader(c));
    }

    list.add(SizedBox(
      height: 100,
    ));

    return list;
  }

}
