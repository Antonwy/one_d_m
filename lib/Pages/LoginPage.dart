import 'dart:collection';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/Components/CustomTextField.dart';
import 'package:one_d_m/Helper/API/ApiResult.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/ContactManager.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Helper/Validate.dart';
import 'package:one_d_m/Pages/HomePage/HomePage.dart';
import 'package:one_d_m/Pages/VerifyEmailPage.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextTheme _textTheme;

  String _password, _email;
  bool _loading = false;

  UserManager _um;

  GlobalKey<FormState> _formKey = GlobalKey();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;
    _um = Provider.of<UserManager>(context);

    if (_um.status == Status.Authenticated)
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.push(context, MaterialPageRoute(builder: (c) => HomePage()));
      });
    else if (_um.status == Status.Unverified && _loading == false) {
      _loading = true;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        try {
          ContactManager.uploadPhoneNumbers(
              await ContactManager.phoneNumberList());
        } on PermissionException catch (e) {
          print(e);
        }

        Navigator.push(
            context, MaterialPageRoute(builder: (c) => VerifyEmailPage()));
      });
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ColorTheme.red,
      appBar: AppBar(
        backgroundColor: ColorTheme.red,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Center(
                    child: SvgPicture.asset(
                  "assets/images/sign-in.svg",
                  height: 200,
                )),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Login",
                  style: _textTheme.headline3.copyWith(
                    color: ColorTheme.whiteBlue,
                  ),
                ),
                Text(
                  "Gib deine Email und dein Passwort ein.",
                  style:
                      _textTheme.caption.copyWith(color: ColorTheme.whiteBlue),
                ),
                SizedBox(
                  height: 20,
                ),
                CustomTextField(
                  label: "Email",
                  hint: "test@gmail.com",
                  preficIcon: Icon(Icons.email),
                  textInputType: TextInputType.emailAddress,
                  textColor: ColorTheme.whiteBlue,
                  focusedColor: ColorTheme.whiteBlue,
                  activeColor: Colors.white54,
                  onChanged: (text) {
                    _email = text.toLowerCase();
                  },
                  validator: Validate.email,
                ),
                SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  label: "Passwort",
                  obscureText: true,
                  preficIcon: Icon(Icons.vpn_key),
                  textInputType: TextInputType.visiblePassword,
                  textColor: ColorTheme.whiteBlue,
                  focusedColor: ColorTheme.whiteBlue,
                  activeColor: Colors.white54,
                  onChanged: (text) {
                    _password = text;
                  },
                  validator: Validate.password,
                ),
                SizedBox(
                  height: 20,
                ),
                FloatingActionButton.extended(
                  onPressed: _um.status == Status.Authenticating || _loading
                      ? null
                      : _login,
                  elevation: 0,
                  highlightElevation: 7,
                  splashColor: ColorTheme.red,
                  hoverColor: ColorTheme.red,
                  focusColor: ColorTheme.red,
                  shape: RoundedRectangleBorder(
                      side: BorderSide(width: 2, color: ColorTheme.whiteBlue),
                      borderRadius: BorderRadius.circular(23)),
                  backgroundColor: ColorTheme.red,
                  icon: _um.status == Status.Authenticating || _loading
                      ? Container(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                              ColorTheme.whiteBlue,
                            ),
                          ),
                        )
                      : Icon(Icons.done, color: ColorTheme.whiteBlue),
                  label: Text(
                    "Login",
                    style: TextStyle(color: ColorTheme.whiteBlue),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    if (!_formKey.currentState.validate()) return;
    ApiResult<FirebaseUser> res = await _um.signIn(_email, _password);

    if (res.hasError()) {
      _showSnackBar(res.message);
    }
  }

  void _showSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }
}
