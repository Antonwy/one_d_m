import 'package:animations/animations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/api/api_result.dart';
import 'package:one_d_m/components/big_button.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/helper/dynamic_link_manager.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:one_d_m/views/users/find_friends_page.dart';
import 'package:provider/provider.dart';

import 'choose_login_method.dart';

class VerifyEmailPage extends StatefulWidget {
  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  TextTheme? _textTheme;

  late UserManager _um;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool _loading = false;

  @override
  void initState() {
    super.initState();

    DynamicLinkManager.of(context).initialize();

    context
        .read<FirebaseAnalytics>()
        .setCurrentScreen(screenName: "Verify Email Page");

    context.read<UserManager>().sendEmailVerification();
  }

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;
    _um = Provider.of<UserManager>(context);
    ThemeData _theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _theme.cardColor,
      appBar: AppBar(
        backgroundColor: _theme.cardColor,
        elevation: 0,
        leading: BackButton(onPressed: () async {
          try {
            await _um.delete();
          } catch (e) {
            print("Löschen failed!");
          }
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (c) => ChooseLoginMethodPage()),
              (route) => route.isFirst);
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loading
            ? null
            : () async {
                setState(() {
                  _loading = true;
                });
                await _um.fireUser!.reload();
                _um.fireUser = _um.auth!.currentUser;
                if (_um.fireUser!.emailVerified) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FindFriendsPage(
                                afterRegister: true,
                              )));
                } else
                  _showSnackBar("Email noch nicht verifiziert.", context);
                setState(() {
                  _loading = false;
                });
              },
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 250),
          child: _loading
              ? LoadingIndicator(size: 16)
              : Icon(
                  Icons.arrow_forward,
                ),
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
              style: _theme.textTheme.headline6,
            ),
            SizedBox(
              height: 10,
            ),
            RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: "Dies läuft wie folgt ab: \n",
                ),
                TextSpan(
                  text: "Wir haben dir eine Email mit einem Link an ",
                ),
                TextSpan(
                    text: "${_um.fireUser!.email} ",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                  text: "geschickt.\n\n",
                ),
                TextSpan(
                  text:
                      "Bitte klicke auf den Link um dich zu verifizieren.\nDanach kannst du wieder in die App zurückkehren und auf weiter klicken!\n\n",
                ),
                TextSpan(
                  text: "Solltest du keine Email erhalten haben, klicke auf ",
                ),
                TextSpan(
                    text: '"Erneut senden"',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ], style: _theme.textTheme.bodyText2),
            ),
            SizedBox(
              height: 20,
            ),
            BigButton(
              onPressed: () async {
                ApiResult res = await _um.sendEmailVerification();

                _showSnackBar(
                    res.hasError() ? res.message! : "Email versendet!",
                    context);
              },
              label: "Erneut senden",
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
