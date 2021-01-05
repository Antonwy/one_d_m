import 'package:flutter/material.dart';
import 'package:one_d_m/Components/UserButton.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
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
                child: FutureBuilder(
                  future: DatabaseService.getUser(userIDs[index]),
                  builder: (context, snapshot) {
                    if(snapshot.hasData) {
                      User user = snapshot.data;
                      return UserButton(
                        userIDs[index],
                        user: user,
                        color: ColorTheme.whiteBlue,
                        textStyle: TextStyle(color: ColorTheme.blue),
                        elevation: 0,
                        avatarColor: ColorTheme.blue,
                      );
                    }else{
                      return SizedBox.shrink();
                    }
                  }
                ),
              );
            },
            itemCount: userIDs.length),
      ),
    );
  }
}
