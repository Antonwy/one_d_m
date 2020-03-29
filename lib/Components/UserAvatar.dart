import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Components/UserPageRoute.dart';
import 'package:one_d_m/Helper/CircularRevealRoute.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Pages/UserPage.dart';

class UserAvatar extends StatelessWidget {
  User user;

  GlobalKey _key = GlobalKey();

  UserAvatar(this.user) : assert(user != null);

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Container(
        width: 70,
        height: 70,
        child: Hero(
          key: _key,
          tag: "user${user.id}",
          child: Material(
              color: Colors.grey[300],
              shape: CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                  onTap: () {
                    Navigator.push(context, UserPageRoute(user));
                  },
                  child: Avatar(user.imgUrl))),
        ),
      ),
      SizedBox(height: 5),
      Text(
        "${user.firstname}\n${user.lastname}",
        textAlign: TextAlign.center,
      )
    ]);
  }
}
