import 'package:flutter/material.dart';
import 'package:one_d_m/Components/UserPageRoute.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/User.dart';

import 'AnimatedFutureBuilder.dart';
import 'Avatar.dart';

class UserButton extends StatelessWidget {
  String id;
  User user;
  Color color;
  TextStyle textStyle;
  double elevation;

  UserButton(this.id,
      {this.user,
      this.color = Colors.white,
      this.textStyle = const TextStyle(color: Colors.black),
      this.elevation = 1});

  @override
  Widget build(BuildContext context) {
    return AnimatedFutureBuilder<User>(
        future: user == null ? DatabaseService.getUser(id) : Future.value(user),
        builder: (context, snapshot) {
          if (snapshot.hasData)
            return Material(
              borderRadius: BorderRadius.circular(5),
              clipBehavior: Clip.antiAlias,
              color: color,
              elevation: elevation,
              child: InkWell(
                onTap: () {
                  Navigator.push(context, UserPageRoute(snapshot.data));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Avatar(snapshot.data?.thumbnailUrl ??
                              snapshot.data.imgUrl),
                          SizedBox(width: 10),
                          Text(
                            "${snapshot.data.name}",
                            style: Theme.of(context)
                                .textTheme
                                .title
                                .merge(textStyle),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          return Container(height: 20);
        });
  }
}
