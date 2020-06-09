import 'package:flutter/material.dart';
import 'package:one_d_m/Components/UserButton.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';

class FollowersListPage extends StatelessWidget {
  String title;
  List<String> userIDs;

  FollowersListPage({this.title, this.userIDs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: ColorTheme.blue,
        brightness: Brightness.dark,
        elevation: 0,
      ),
      backgroundColor: ColorTheme.blue,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: UserButton(
                  userIDs[index],
                  color: ColorTheme.blue,
                  textStyle: TextStyle(color: ColorTheme.whiteBlue),
                  elevation: 0,
                  avatarColor: ColorTheme.whiteBlue,
                ),
              );
            },
            itemCount: userIDs.length),
      ),
    );
  }
}
