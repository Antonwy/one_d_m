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
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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
      backgroundColor: ColorTheme.whiteBlue,
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
              style: _theme.textTheme.headline5.copyWith(
                  color: ColorTheme.blue, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Logge dich ein, um Mitglied von One Dollar Movement zu werden!",
              style: _theme.textTheme.subtitle1
                  .copyWith(color: ColorTheme.blue.withOpacity(.5)),
              textAlign: TextAlign.center,
            ),
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
            SignInWithAppleButton(
              onPressed: _appleSignIn,
              text: "Mit Apple anmelden",
              height: 52,
              style: SignInWithAppleButtonStyle.white,
              borderRadius: BorderRadius.circular(12),
            ),
            SizedBox(
              height: 10,
            ),
            SignInButton(Buttons.Google,
                text: "Mit Google einloggen", onPressed: _googleSignIn),
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

  void _appleSignIn() async {
    UserManager um = Provider.of<UserManager>(context, listen: false);
    setState(() {
      _loading = true;
    });

    _nextStepsSocialSignIn(await um.signInWithApple());
  }

  void _googleSignIn() async {
    UserManager um = Provider.of<UserManager>(context, listen: false);
    setState(() {
      _loading = true;
    });
    _nextStepsSocialSignIn(await um.signInWithGoogle());
  }

  void _nextStepsSocialSignIn(ApiResult res) async {
    print(res);

    if (res.hasError() || res.data == null) {
      setState(() {
        _loading = false;
      });
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(res.message)));
      return;
    }

    if (await DatabaseService.checkIfUserHasAlreadyAnAccount(res.data.uid)) {
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
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        openColor: pageColor,
        closedElevation: 0,
        closedColor: isRegister ? ColorTheme.blue : ColorTheme.orange,
        closedBuilder: (context, open) => Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            color: isRegister ? null : ColorTheme.orange,
          ),
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
