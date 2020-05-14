import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Pages/LoginPage.dart';
import 'package:one_d_m/Pages/NewRegisterPage.dart';

class ChooseLoginMethodPage extends StatelessWidget {
  ThemeData _theme;

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
              height: 200,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Willkommen",
              style: _theme.textTheme.headline4
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
            Padding(
              padding: const EdgeInsets.all(18.0),
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
            )
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
        closedColor: isRegister ? ColorTheme.blue : ColorTheme.red,
        closedBuilder: (context, open) => Container(
          height: 52,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              color: isRegister ? null : ColorTheme.red,
              border: isRegister
                  ? Border.all(width: 2, color: Colors.white)
                  : Border()),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: open,
              child: Center(
                  child: Text(
                isRegister ? "Registrieren" : "Login",
                style: TextStyle(
                    color: isRegister ? Colors.white : ColorTheme.blue,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              )),
            ),
          ),
        ),
      ),
    );
  }
}
