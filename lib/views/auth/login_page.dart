import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/api/api_result.dart';
import 'package:one_d_m/components/custom_text_field.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/components/reset_password_dialog.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/contact_manager.dart';
import 'package:one_d_m/helper/validate.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:one_d_m/views/auth/verify_email_page.dart';
import 'package:one_d_m/views/home/home_page.dart';
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
  void initState() {
    context.read<FirebaseAnalytics>().setCurrentScreen(screenName: "LoginPage");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;
    _um = Provider.of<UserManager>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ColorTheme.appGrey,
      body: Form(
        key: _formKey,
        child: CustomScrollView(slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            leading: BackButton(
              color: ColorTheme.blue,
              onPressed: () {
                _um.status = Status.Unauthenticated;
                Navigator.pop(context);
              },
            ),
            elevation: 0,
          ),
          SliverFillRemaining(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Login",
                        style: _textTheme.headline3.copyWith(
                          color: ColorTheme.blue,
                        ),
                      ),
                      Text(
                        "Gib deine Email und dein Passwort ein.",
                        style:
                            _textTheme.caption.copyWith(color: ColorTheme.blue),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      CustomTextField(
                        label: "Email",
                        hint: "tester@gmail.com",
                        preficIcon: Icon(Icons.email),
                        textInputType: TextInputType.emailAddress,
                        textColor: ColorTheme.blue,
                        focusedColor: ColorTheme.blue,
                        activeColor: ColorTheme.blue,
                        autoCorrect: false,
                        inputFormatter: [UserNameFormatter()],
                        onChanged: (text) {
                          _email = text.trim().toLowerCase();
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
                        textColor: ColorTheme.blue,
                        focusedColor: ColorTheme.blue,
                        activeColor: ColorTheme.blue,
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
                            splashColor: ColorTheme.appGrey,
                            hoverColor: ColorTheme.appGrey,
                            focusColor: ColorTheme.appGrey,
                            shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    width: 2, color: ColorTheme.blue),
                                borderRadius: BorderRadius.circular(23)),
                            backgroundColor: ColorTheme.appGrey,
                            icon:
                                _um.status == Status.Authenticating || _loading
                                    ? Container(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation(
                                            ColorTheme.blue,
                                          ),
                                        ),
                                      )
                                    : Icon(Icons.done, color: ColorTheme.blue),
                            label: Text(
                              "Login",
                              style: TextStyle(color: ColorTheme.blue),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              String msg = await showDialog(
                                  context: context,
                                  builder: (context) => ResetPasswordDialog());
                              if (msg != null) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text(msg)));
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Passwort zurücksetzen",
                                style: TextStyle(
                                    color: ColorTheme.blue,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          ),
                        ],
                      ),
                      YMargin(30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void _login() async {
    if (!_formKey.currentState.validate()) return;
    ApiResult<User> res = await _um.signIn(_email, _password);

    if (res.hasError()) {
      _showSnackBar(res.message);
    }

    if (_um.status == Status.Authenticated) {
      context.read<FirebaseAnalytics>().logLogin();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (route) => route.isCurrent);
    }

    if (_um.status == Status.Unverified && !_loading) {
      _loading = true;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        try {
          ContactManager cm = ContactManager();
          cm.uploadPhoneNumbers(await cm.phoneNumberList());
        } on PermissionException catch (e) {
          print(e);
        }

        Navigator.push(
            context, MaterialPageRoute(builder: (c) => VerifyEmailPage()));
      });
    }

    await _um.afterAuthentication();
  }

  void _showSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }
}
