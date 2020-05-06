import 'package:flutter/material.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Components/UserPageRoute.dart';
import 'package:one_d_m/Helper/User.dart';

class UserAvatar extends StatelessWidget {
  User user;

  UserAvatar(this.user) : assert(user != null);

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Container(
        width: 70,
        height: 70,
        child: Avatar(user?.thumbnailUrl ?? user.imgUrl, onTap: () {
          Navigator.push(context, UserPageRoute(user));
        }),
      ),
      SizedBox(height: 5),
      Text(
        "${user.firstname ?? "Laden..."}\n${user.lastname ?? ""}",
        textAlign: TextAlign.center,
      )
    ]);
  }
}
