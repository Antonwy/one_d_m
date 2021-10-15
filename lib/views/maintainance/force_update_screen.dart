import 'dart:io';
import 'package:flutter/material.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/ic_onedm.png',
                width: 250,
                height: 200,
              ),
              Text(
                "NEUES UPDATE!",
                style: _theme.textTheme.headline6,
              ),
              YMargin(12),
              Text(
                "Wir haben ein neues Update veröffentlicht. Gehe jetzt in den ${Platform.isAndroid ? "PlayStore" : "Appstore"} um es herunterzuladen!",
                style: _theme.textTheme.bodyText1,
                textAlign: TextAlign.center,
              ),
              YMargin(12),
              ElevatedButton(
                onPressed: () async {
                  if (await canLaunch(Constants.STORE_LINK)) {
                    launch(Constants.STORE_LINK);
                  }
                },
                child: Text("Update herunterladen"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
