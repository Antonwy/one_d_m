import 'package:flutter/material.dart';
import 'package:one_d_m/Components/DonationWidget.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Donation.dart';
import 'package:one_d_m/Helper/User.dart';

class UsersDonationsPage extends StatelessWidget {
  final User user;

  UsersDonationsPage(this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Spenden")),
      body: StreamBuilder<List<Donation>>(
        stream: DatabaseService().getDonationsFromUser(user),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: DonationWidget(snapshot.data[index]),
                  );
                });
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
