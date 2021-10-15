import 'package:flutter/material.dart';
import 'package:one_d_m/components/users/user_button.dart';
import 'package:one_d_m/models/user.dart';

class FollowersListPage extends StatelessWidget {
  final Future<List<User?>>? usersFuture;
  final String? title;

  FollowersListPage({this.usersFuture, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title!,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: FutureBuilder<List<User?>>(
            initialData: [],
            future: usersFuture,
            builder: (context, snapshot) {
              return ListView.builder(
                  itemBuilder: (context, index) {
                    return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: UserButton(
                          snapshot.data![index]!.id,
                          withAddButton: true,
                          user: snapshot.data![index],
                          elevation: 0,
                        ));
                  },
                  itemCount: snapshot.data?.length ?? 0);
            }),
      ),
    );
  }
}
