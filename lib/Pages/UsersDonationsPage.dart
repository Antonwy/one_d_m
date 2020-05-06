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
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: StreamBuilder<List<Donation>>(
          stream: DatabaseService.getDonationsFromUser(user.id),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5),
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return DonationWidget(snapshot.data[index]);
                  });
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
