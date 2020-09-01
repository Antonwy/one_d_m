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
        title: Text(
          title,
          style: TextStyle(color: ColorTheme.blue),
        ),
        iconTheme: IconThemeData(color: ColorTheme.blue),
        backgroundColor: ColorTheme.whiteBlue,
        brightness: Brightness.light,
        elevation: 0,
      ),
      backgroundColor: ColorTheme.whiteBlue,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: UserButton(
                  userIDs[index],
                  color: ColorTheme.whiteBlue,
                  textStyle: TextStyle(color: ColorTheme.blue),
                  elevation: 0,
                  avatarColor: ColorTheme.blue,
                ),
              );
            },
            itemCount: userIDs.length),
      ),
    );
  }
}
