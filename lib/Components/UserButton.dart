import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Pages/UserPage.dart';

import 'AnimatedFutureBuilder.dart';

class UserButton extends StatelessWidget {
  String id;

  UserButton(this.id);

  @override
  Widget build(BuildContext context) {
    return AnimatedFutureBuilder<User>(
        future: DatabaseService(id).getUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData)
            return Material(
              borderRadius: BorderRadius.circular(5),
              clipBehavior: Clip.antiAlias,
              color: Colors.white,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) => UserPage(snapshot.data)));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        child: Icon(Icons.person),
                        backgroundImage: snapshot.data.imgUrl != null
                            ? NetworkImage(snapshot.data.imgUrl)
                            : null,
                      ),
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
