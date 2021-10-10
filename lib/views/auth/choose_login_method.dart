import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/api/api_result.dart';
import 'package:one_d_m/components/big_button.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/helper/database_service.dart';
import 'package:one_d_m/views/auth/register_page.dart';
import 'package:one_d_m/views/home/home_page.dart';

import 'login_page.dart';

class ChooseLoginMethodPage extends StatefulWidget {
  @override
  _ChooseLoginMethodPageState createState() => _ChooseLoginMethodPageState();
}

class _ChooseLoginMethodPageState extends State<ChooseLoginMethodPage> {
  late ThemeData _theme;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);

    SystemChrome.setSystemUIOverlayStyle(context.systemOverlayStyle);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              "assets/images/img_login_register.svg",
              height: MediaQuery.of(context).size.height * .25,
            ),
            SizedBox(
              height: 24,
            ),
            Text(
              "Willkommen",
              style: _theme.textTheme.headline5!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Registriere dich, um Mitglied von One Dollar Movement zu werden!",
              style: _theme.textTheme.subtitle1!.withOpacity(.7),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 28, 0, 6),
              child: Container(
                width: 200,
                child: BigButton(
                    fontSize: 16,
                    label: "Registrieren",
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterPage()));
                    },
                    color: _theme.colorScheme.secondary),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Falls du einen account hast: ",
                    style: _theme.textTheme.caption!),
                TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (c) => LoginPage()));
                    },
                    child: Text(
                      "Einloggen",
                      style: TextStyle(decoration: TextDecoration.underline),
                    )),
              ],
            ),
            // SignInWithAppleButton(
            //   onPressed: _appleSignIn,
            //   text: "Mit Apple anmelden",
            //   height: 52,
            //   style: SignInWithAppleButtonStyle.black,
            //   borderRadius: BorderRadius.circular(12),
            // ),
            // SizedBox(
            //   height: 10,
            // ),
            // SignInButton(Buttons.Google,
            //     text: "Mit Google einloggen", onPressed: _googleSignIn),
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

  // void _appleSignIn() async {
  //   UserManager um = Provider.of<UserManager>(context, listen: false);
  //   setState(() {
  //     _loading = true;
  //   });

  //   _nextStepsSocialSignIn(await um.signInWithApple());
  // }

  // void _googleSignIn() async {
  //   UserManager um = Provider.of<UserManager>(context, listen: false);
  //   setState(() {
  //     _loading = true;
  //   });
  //   _nextStepsSocialSignIn(await um.signInWithGoogle());
  // }

  void _nextStepsSocialSignIn(ApiResult res) async {
    print(res);

    if (res.hasError() || res.data == null) {
      setState(() {
        _loading = false;
      });
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(res.message!)));
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
            builder: (context) => RegisterPage(
                  socialSignIn: true,
                )));
  }
}

class _RoundButton extends StatelessWidget {
  bool isRegister;
  Widget? toPage;
  Color? color;

  _RoundButton(this.isRegister, {this.toPage, this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 52,
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(Constants.radius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => toPage!));
            },
            child: Center(
                child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: AutoSizeText(
                isRegister ? "Registrieren" : "Login",
                maxLines: 1,
                style: TextStyle(
                    color: context.theme.correctColorFor(color!),
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
            )),
          ),
        ),
      ),
    );
  }
}
