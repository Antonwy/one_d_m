import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/Components/CustomTextField.dart';
import 'package:one_d_m/Components/ResetPasswordDialog.dart';
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
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
            (route) => route.isFirst);
      });
    if (_um.status == Status.Unverified && _loading == false) {
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
      backgroundColor: ColorTheme.orange,
      body: Form(
        key: _formKey,
        child: CustomScrollView(slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Center(
                    child: SvgPicture.asset(
                  "assets/images/sign-in.svg",
                  height: MediaQuery.of(context).size.height * .25,
                )),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Login",
                        style: _textTheme.headline3.copyWith(
                          color: ColorTheme.whiteBlue,
                        ),
                      ),
                      Text(
                        "Gib deine Email und dein Passwort ein.",
                        style: _textTheme.caption
                            .copyWith(color: ColorTheme.whiteBlue),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      CustomTextField(
                        label: "Email",
                        hint: "tester@gmail.com",
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          FloatingActionButton.extended(
                            onPressed:
                                _um.status == Status.Authenticating || _loading
                                    ? null
                                    : _login,
                            elevation: 0,
                            highlightElevation: 7,
                            splashColor: ColorTheme.orange,
                            hoverColor: ColorTheme.orange,
                            focusColor: ColorTheme.orange,
                            shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    width: 2, color: ColorTheme.whiteBlue),
                                borderRadius: BorderRadius.circular(23)),
                            backgroundColor: ColorTheme.orange,
                            icon: _um.status == Status.Authenticating ||
                                    _loading
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
                          ),
                          Consumer<UserManager>(
                            builder: (context, um, child) => InkWell(
                              onTap: () async {
                                String msg = await showDialog(
                                    context: context,
                                    builder: (context) =>
                                        ResetPasswordDialog());
                                if (msg != null) {
                                  Scaffold.of(context).showSnackBar(
                                      SnackBar(content: Text(msg)));
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Passwort zurücksetzen",
                                  style: TextStyle(
                                      color: ColorTheme.whiteBlue,
                                      decoration: TextDecoration.underline),
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]),
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
