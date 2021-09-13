import 'package:flutter/material.dart';
import 'package:one_d_m/components/user_button.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/database_service.dart';
import 'package:one_d_m/models/user.dart';

class FollowersListPage extends StatelessWidget {
  final Future<List<User>> usersFuture;
  final String title;

  FollowersListPage({this.usersFuture, this.title});

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
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: FutureBuilder<List<User>>(
            initialData: [],
            future: usersFuture,
            builder: (context, snapshot) {
              return ListView.builder(
                  itemBuilder: (context, index) {
                    return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: UserButton(
                          snapshot.data[index].id,
                          withAddButton: true,
                          user: snapshot.data[index],
                          color: ColorTheme.whiteBlue,
                          textStyle: TextStyle(color: ColorTheme.blue),
                          elevation: 0,
                          avatarColor: ColorTheme.blue,
                        ));
                  },
                  itemCount: snapshot.data?.length ?? 0);
            }),
      ),
    );
  }
}
