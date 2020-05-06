import 'package:flutter/material.dart';
import 'package:one_d_m/Components/AnimatedFutureBuilder.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Components/UserButton.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: ListView.builder(
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: UserButton(userIDs[index]),
              );
              
            },
            itemCount: userIDs.length),
      ),
    );
  }
}
