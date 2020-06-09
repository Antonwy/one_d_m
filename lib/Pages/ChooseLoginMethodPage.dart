import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/Helper/API/ApiResult.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/LoginPage.dart';
import 'package:one_d_m/Pages/NewRegisterPage.dart';
import 'package:provider/provider.dart';

import 'HomePage/HomePage.dart';

class ChooseLoginMethodPage extends StatefulWidget {
  @override
  _ChooseLoginMethodPageState createState() => _ChooseLoginMethodPageState();
}

class _ChooseLoginMethodPageState extends State<ChooseLoginMethodPage> {
  ThemeData _theme;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    return Scaffold(
      backgroundColor: ColorTheme.blue,
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              "assets/images/login.svg",
              height: MediaQuery.of(context).size.height * .25,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Willkommen",
              style: _theme.textTheme.headline5
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Logge dich ein, um Mitglied von One Dollar Movement zu werden!",
              style: _theme.textTheme.subtitle1.copyWith(color: Colors.white54),
              textAlign: TextAlign.center,
            ),

            // SignInWithAppleButton(
            //   onPressed: () {},
            //   text: "Mit Apple anmelden",
            //   height: 52,
            //   style: SignInWithAppleButtonStyle.white,
            //   borderRadius: BorderRadius.circular(26),
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              child: Row(
                children: <Widget>[
                  _RoundButton(false,
                      toPage: LoginPage(), pageColor: ColorTheme.yellow),
                  SizedBox(
                    width: 12,
                  ),
                  _RoundButton(true,
                      toPage: NewRegisterPage(), pageColor: ColorTheme.blue),
                ],
              ),
            ),
            Consumer<UserManager>(
              builder: (context, um, child) => SignInButton(
                Buttons.GoogleDark,
                text: "Mit Google einloggen",
                onPressed: () async {
                  setState(() {
                    _loading = true;
                  });
                  ApiResult<FirebaseUser> res = await um.signInWithGoogle();

                  print(res);

                  if (res.hasError() || res.data == null) {
                    setState(() {
                      _loading = false;
                    });
                    Scaffold.of(context)
                        .showSnackBar(SnackBar(content: Text(res.message)));
                    return;
                  }

                  if (await DatabaseService.checkIfUserHasAlreadyAnAccount(
                      res.data.uid)) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                        (route) => route.isFirst);
                    return;
                  }

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NewRegisterPage(
                                socialSignIn: true,
                              )));
                },
              ),
            ),
            // SignInButton(
            //   Buttons.Apple,
            //   onPressed: () {},
            // ),
            _loading
                ? SizedBox(
                    height: 20,
                  )
                : Container(),
            _loading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(ColorTheme.whiteBlue),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  bool isRegister;
  Widget toPage;
  Color pageColor;

  _RoundButton(this.isRegister, {this.toPage, this.pageColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OpenContainer(
        openBuilder: (context, close) => toPage,
        closedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        openColor: pageColor,
        closedElevation: 0,
        closedColor: isRegister ? ColorTheme.blue : ColorTheme.orange,
        closedBuilder: (context, open) => Container(
          height: 52,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              color: isRegister ? null : ColorTheme.orange,
              border: isRegister
                  ? Border.all(width: 2, color: Colors.white)
                  : Border()),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: open,
              child: Center(
                  child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: AutoSizeText(
                  isRegister ? "Registrieren" : "Login",
                  maxLines: 1,
                  style: TextStyle(
                      color: isRegister ? Colors.white : ColorTheme.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
              )),
            ),
          ),
        ),
      ),
    );
  }
}
