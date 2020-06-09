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
        title: Text("Spenden"),
        backgroundColor: ColorTheme.blue,
        brightness: Brightness.dark,
        elevation: 0,
      ),
      backgroundColor: ColorTheme.blue,
      body: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: StreamBuilder<List<Donation>>(
          stream: DatabaseService.getDonationsFromUser(user.id),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemBuilder: (context, index) {
                  return DonationWidget(
                    snapshot.data[index],
                    backgroundLight: false,
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
