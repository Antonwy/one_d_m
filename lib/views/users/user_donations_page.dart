import 'package:flutter/material.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/components/donation_widget.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/database_service.dart';
import 'package:one_d_m/models/donation.dart';
import 'package:one_d_m/models/user.dart';

class UsersDonationsPage extends StatelessWidget {
  final User? user;

  UsersDonationsPage(this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "Unterstützt",
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: FutureBuilder<List<Donation?>>(
          future: Api().donations().user(user!.id).get(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemBuilder: (context, index) {
                  return DonationWidget(
                    snapshot.data![index]!,
                    withUsername: false,
                  );
                },
                itemCount: snapshot.data!.length,
              );
            }
            return Center(
              child: LoadingIndicator(
                message: "Lade Unterstützungen...",
              ),
            );
          },
        ),
      ),
    );
  }
}
