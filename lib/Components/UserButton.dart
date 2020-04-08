import 'package:flutter/material.dart';
import 'package:one_d_m/Components/UserPageRoute.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/User.dart';

import 'AnimatedFutureBuilder.dart';
import 'Avatar.dart';

class UserButton extends StatelessWidget {
  String id;
  User user;

  UserButton(this.id, {this.user});

  @override
  Widget build(BuildContext context) {
    return AnimatedFutureBuilder<User>(
        future:
            user == null ? DatabaseService(id).getUser() : Future.value(user),
        builder: (context, snapshot) {
          if (snapshot.hasData)
            return Material(
              borderRadius: BorderRadius.circular(5),
              clipBehavior: Clip.antiAlias,
              color: Colors.white,
              child: InkWell(
                onTap: () {
                  Navigator.push(context, UserPageRoute(snapshot.data));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Avatar(snapshot.data.imgUrl),
                      SizedBox(width: 10),
                      Text(
                        "${snapshot.data.firstname} ${snapshot.data.lastname}",
                        style: Theme.of(context).textTheme.title,
                      )
                    ],
                  ),
                ),
              ),
            );
          return Container(height: 20);
        });
  }
}
