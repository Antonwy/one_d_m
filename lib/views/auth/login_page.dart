import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:one_d_m/api/api_result.dart';
import 'package:one_d_m/components/big_button.dart';
import 'package:one_d_m/components/custom_text_field.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/components/reset_password_dialog.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/contact_manager.dart';
import 'package:one_d_m/helper/validate.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:one_d_m/views/auth/verify_email_page.dart';
import 'package:one_d_m/views/home/home_page.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextTheme _textTheme;

  String? _password, _email;

  bool _loading = false;

  late UserManager _um;

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
    ThemeData _theme = Theme.of(context);
    _um = Provider.of<UserManager>(context);

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: _theme.cardColor,
      body: AnimatedPadding(
        duration: Duration(milliseconds: 1000),
        curve: Curves.fastLinearToSlowEaseIn,
        padding: MediaQuery.of(context).viewInsets,
        child: Form(
          key: _formKey,
          child: CustomScrollView(slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              systemOverlayStyle: context.systemOverlayStyle,
              title: Text("Login"),
              leading: BackButton(
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
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Center(
                            child: SvgPicture.asset(
                                "assets/images/img_login.svg",
                                height: MediaQuery.of(context).size.width * .5),
                          ),
                          SizedBox(
                            height: 24,
                          ),
                          CustomTextField(
                            autofillHints: [AutofillHints.email],
                            label: "Email",
                            hint: "tester@gmail.com",
                            preficIcon: Icon(Icons.email),
                            textInputType: TextInputType.emailAddress,
                            textColor: _theme.colorScheme.onBackground,
                            focusedColor: _theme.colorScheme.onBackground,
                            activeColor:
                                _theme.colorScheme.onBackground.withOpacity(.4),
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
                            autofillHints: [AutofillHints.password],
                            label: "Passwort",
                            obscureText: true,
                            preficIcon: Icon(Icons.vpn_key),
                            textInputType: TextInputType.visiblePassword,
                            textColor: _theme.colorScheme.onBackground,
                            focusedColor: _theme.colorScheme.onBackground,
                            activeColor:
                                _theme.colorScheme.onBackground.withOpacity(.4),
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
                              BigButton(
                                  onPressed:
                                      _um.status == Status.Authenticating ||
                                              _loading
                                          ? null
                                          : _login,
                                  loading:
                                      _um.status == Status.Authenticating ||
                                          _loading,
                                  color: _theme.colorScheme.secondary,
                                  label: "Login"),
                              Builder(builder: (context) {
                                return TextButton(
                                  onPressed: () async {
                                    String? msg = await showDialog(
                                        context: context,
                                        builder: (context) =>
                                            ResetPasswordDialog());
                                    if (msg != null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                              SnackBar(content: Text(msg)));
                                    }
                                  },
                                  child: Text(
                                    "Passwort zurücksetzen",
                                    style: TextStyle(
                                        decoration: TextDecoration.underline),
                                  ),
                                );
                              }),
                            ],
                          ),
                          YMargin(30),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _login() async {
    if (!_formKey.currentState!.validate() ||
        _email == null ||
        _password == null) return;
    ApiResult<User> res = await _um.signIn(_email!, _password!);

    if (res.hasError()) {
      _showSnackBar(res.message!);
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
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
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
    _scaffoldKey.currentState!.showSnackBar(SnackBar(content: Text(message)));
  }
}
