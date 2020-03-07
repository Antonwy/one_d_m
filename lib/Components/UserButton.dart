import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/API/Api.dart';
import 'package:one_d_m/Helper/API/ApiResult.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Pages/UserPage.dart';

import 'AnimatedFutureBuilder.dart';

class UserButton extends StatelessWidget {
  int id;

  UserButton(this.id);

  @override
  Widget build(BuildContext context) {
    return AnimatedFutureBuilder<ApiResult<User>>(
        future: Api.getUserWithId(id),
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
                          builder: (c) => UserPage(snapshot.data.getData())));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "${snapshot.data.getData().firstname} ${snapshot.data.getData().lastname}",
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
