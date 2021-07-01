import 'package:animations/animations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/Helper/API/ApiResult.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/ChooseLoginMethodPage.dart';
import 'package:one_d_m/Pages/FindFriendsPage.dart';
import 'package:provider/provider.dart';

class VerifyEmailPage extends StatefulWidget {
  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  TextTheme _textTheme;

  UserManager _um;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    context
        .read<FirebaseAnalytics>()
        .setCurrentScreen(screenName: "Verify Email Page");
  }

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;
    _um = Provider.of<UserManager>(context);
    ThemeManager _theme = ThemeManager.of(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _theme.colors.contrast,
      appBar: AppBar(
        backgroundColor: _theme.colors.contrast,
        elevation: 0,
        leading: BackButton(
            color: _theme.colors.textOnContrast,
            onPressed: () async {
              await _um.delete();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (c) => ChooseLoginMethodPage()),
                  (route) => route.isFirst);
            }),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _theme.colors.dark,
        onPressed: _loading
            ? null
            : () async {
                setState(() {
                  _loading = true;
                });
                await _um.fireUser.reload();
                _um.fireUser = _um.auth.currentUser;
                if (_um.fireUser.emailVerified) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FindFriendsPage(
                                afterRegister: true,
                              )));
                } else
                  _showSnackBar("Email noch nicht verifiziert.");
                setState(() {
                  _loading = false;
                });
              },
        child: _loading
            ? Padding(
                padding: const EdgeInsets.all(12.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(_theme.colors.textOnDark),
                ),
              )
            : Icon(
                Icons.arrow_forward,
                color: _theme.colors.textOnDark,
              ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: SvgPicture.asset(
                "assets/images/verify.svg",
                height: MediaQuery.of(context).size.height * .25,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Um fortzufahren musst du deine Email verifizieren!",
              style: _theme.textTheme.dark.headline6,
            ),
            SizedBox(
              height: 10,
            ),
            RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: "Dies läuft wie folgt ab: \nWenn du auf ",
                ),
                TextSpan(
                  text: "\"Email senden\" ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      "klickst, schicken wir dir eine Email mit einem Link an ",
                ),
                TextSpan(
                    text: "${_um.fireUser.email}. ",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                  text:
                      "Bitte klicke auf den Link um dich zu verifizieren.\nDanach kannst du wieder in die App zurückkehren und auf weiter klicken!",
                ),
              ], style: _theme.textTheme.dark.bodyText2),
            ),
            SizedBox(
              height: 20,
            ),
            FloatingActionButton.extended(
              heroTag: "w",
              onPressed: () async {
                ApiResult res = await _um.sendEmailVerification();
                _showSnackBar(
                    res.hasError() ? res.message : "Email versendet!");
              },
              elevation: 2,
              label: Text(
                "Email senden",
                style: TextStyle(color: _theme.colors.textOnDark),
              ),
              icon: Icon(
                Icons.email,
                color: _theme.colors.textOnDark,
              ),
              backgroundColor: _theme.colors.dark,
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }
}
