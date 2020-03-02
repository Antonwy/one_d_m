import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/HomePage/HomePage.dart';
import 'package:provider/provider.dart';

class ExplanationPage extends StatelessWidget {
  User user;

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserManager>(context).user;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset("assets/images/clip-1.png"),
          Text(
            "Willkommen ${user.firstname} ${user.lastname}!",
            style: Theme.of(context).accentTextTheme.title,
          ),
          SizedBox(
            height: 20,
          ),
          OutlineButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => HomePage()));
            },
            child: Text(
              "Anleitung überspringen",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
