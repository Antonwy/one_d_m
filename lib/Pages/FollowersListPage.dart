import 'package:flutter/material.dart';
import 'package:one_d_m/Components/AnimatedFutureBuilder.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Components/UserPageRoute.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/User.dart';

class FollowersListPage extends StatelessWidget {
  String title;
  List<String> userIDs;

  FollowersListPage({this.title, this.userIDs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.builder(
          itemBuilder: (context, index) {
            return AnimatedFutureBuilder<User>(
                future: DatabaseService().getUserFromId(userIDs[index]),
                builder: (context, snapshot) {
                  User user = snapshot.data;
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context, UserPageRoute(user));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            Avatar(
                              user?.imgUrl,
                            ),
                            SizedBox(width: 10),
                            Text(
                              user != null
                                  ? "${user.firstname} ${user.lastname}"
                                  : "Laden...",
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
          },
          itemCount: userIDs.length),
    );
  }
}
