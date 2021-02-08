import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/DonationWidget.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Donation.dart';
import 'package:one_d_m/Helper/User.dart';

class UsersDonationsPage extends StatelessWidget {
  final User user;

  UsersDonationsPage(this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Unterstützt",
          style: TextStyle(color: ColorTheme.blue),
        ),
        iconTheme: IconThemeData(color: ColorTheme.blue),
        backgroundColor: ColorTheme.whiteBlue,
        brightness: Brightness.light,
        elevation: 0,
      ),
      backgroundColor: ColorTheme.whiteBlue,
      body: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: StreamBuilder<List<Donation>>(
          stream: DatabaseService.getDonationsFromUser(user.id),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              snapshot.data.sort(
                  (d1, d2) => d1.createdAt.isAfter(d2.createdAt) ? -1 : 1);
              return ListView.builder(
                itemBuilder: (context, index) {
                  print(snapshot.data[index].userId);
                  return DonationWidget(
                    snapshot.data[index],
                    withUsername: false,
                  );
                },
                itemCount: snapshot.data.length,
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
