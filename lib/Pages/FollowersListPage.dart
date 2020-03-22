import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Pages/UserPage.dart';

class FollowersListPage extends StatelessWidget {
  String title;
  List<User> users;

  FollowersListPage({this.title, this.users});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.builder(
          itemBuilder: (context, index) {
            User user = users[index];
            return Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => UserPage(user)));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        child: user.imgUrl == null ? Icon(Icons.person) : null,
                        backgroundImage: user.imgUrl == null
                            ? null
                            : CachedNetworkImageProvider(user.imgUrl),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "${user.firstname} ${user.lastname}",
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          itemCount: users.length),
    );
  }
}
