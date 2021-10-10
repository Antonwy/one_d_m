import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:one_d_m/api/api_result.dart';
import 'package:one_d_m/components/big_button.dart';
import 'package:one_d_m/components/custom_text_field.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/helper/validate.dart';
import 'package:one_d_m/models/user.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:one_d_m/views/users/find_friends_page.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'verify_email_page.dart';

class RegisterPage extends StatefulWidget {
  bool socialSignIn;

  RegisterPage({this.socialSignIn = false});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late UserManager _um;

  late TextTheme _textTheme;

  File? _profileImage;

  GlobalKey<FormState> _formKey = GlobalKey();

  String? _email, _username, _phone, _password1, _password2;
  bool? _loading = false, _socialSignIn, _acceptedAGBs = false;

  @override
  void initState() {
    context.read<FirebaseAnalytics>().setCurrentScreen(screenName: "LoginPage");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    _textTheme = _theme.textTheme;
    _um = Provider.of<UserManager>(context);
    _socialSignIn = widget.socialSignIn;

    return Scaffold(
      backgroundColor: _theme.cardColor,
      body: Center(
        child: Form(
          key: _formKey,
          child: AutofillGroup(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  systemOverlayStyle: context.systemOverlayStyle,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title:
                      Text(_socialSignIn! ? "Weitere Daten" : "Registrieren"),
                  leading: BackButton(
                    onPressed: () {
                      _um.status = Status.Unauthenticated;
                      Navigator.pop(context);
                    },
                  ),
                ),
                SliverPadding(
                    padding: const EdgeInsets.all(18.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        <Widget>[
                          _socialSignIn!
                              ? AutoSizeText(
                                  "Zum Beenden deiner Registrierung brauchen wir noch ein paar Daten!",
                                  maxLines: 2,
                                  style: _textTheme.bodyText1!)
                              : Row(
                                  children: <Widget>[
                                    Container(
                                      width: 70,
                                      height: 70,
                                      child: Card(
                                        elevation: 10,
                                        color: _theme.primaryColor,
                                        child: InkWell(
                                            onTap: () async {
                                              ImagePicker _picker =
                                                  ImagePicker();
                                              XFile? pickedImage =
                                                  await _picker.pickImage(
                                                      source:
                                                          ImageSource.gallery);

                                              if (pickedImage != null) {
                                                _profileImage =
                                                    File(pickedImage.path);
                                                setState(() {});
                                              }
                                            },
                                            child: _profileImage != null
                                                ? Image.file(
                                                    _profileImage!,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Icon(Icons.add,
                                                    color: _theme.colorScheme
                                                        .onPrimary)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            "Profilbild",
                                            style: _textTheme.headline6!,
                                          ),
                                          Text(
                                            "Wenn du magst, kannst du hier ein Bild von dir hochladen.",
                                            style: _theme.textTheme.bodyText2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                          SizedBox(
                            height: _socialSignIn! ? 0 : 20,
                          ),
                          _socialSignIn!
                              ? Container()
                              : CustomTextField(
                                  label: "Email",
                                  autofillHints: [AutofillHints.email],
                                  hint: "test@gmail.com",
                                  preficIcon: Icon(Icons.email),
                                  textInputType: TextInputType.emailAddress,
                                  autoCorrect: false,
                                  onChanged: (text) {
                                    _email = text.trim().toLowerCase();
                                  },
                                  validator: Validate.email,
                                  textColor: _theme.colorScheme.onBackground,
                                  focusedColor: _theme.colorScheme.onBackground,
                                  activeColor: _theme.colorScheme.onBackground
                                      .withOpacity(.4),
                                ),
                          SizedBox(
                            height: 10,
                          ),
                          CustomTextField(
                            autofillHints: [AutofillHints.newUsername],
                            label: "Nutzername",
                            preficIcon: Icon(
                              Icons.person,
                            ),
                            textInputType: TextInputType.text,
                            autoCorrect: false,
                            inputFormatter: [
                              FilteringTextInputFormatter.allow(
                                  RegExp("[a-z0-9-._]"))
                            ],
                            onChanged: (text) {
                              _username = text.trim();
                            },
                            maxLength: 15,
                            validator: Validate.username,
                            textColor: _theme.colorScheme.onBackground,
                            focusedColor: _theme.colorScheme.onBackground,
                            activeColor:
                                _theme.colorScheme.onBackground.withOpacity(.4),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          !_socialSignIn! ||
                                  (_socialSignIn! &&
                                      _um.fireUser?.phoneNumber == null)
                              ? CustomTextField(
                                  label: "Telefonnummer",
                                  autofillHints: [
                                    AutofillHints.telephoneNumber
                                  ],
                                  preficIcon: Icon(
                                    Icons.phone,
                                  ),
                                  textInputType: TextInputType.phone,
                                  onChanged: (text) {
                                    _phone = text;
                                  },
                                  validator: Validate.telephone,
                                  textColor: _theme.colorScheme.onBackground,
                                  focusedColor: _theme.colorScheme.onBackground,
                                  activeColor: _theme.colorScheme.onBackground
                                      .withOpacity(.4),
                                )
                              : Container(),
                          SizedBox(
                            height: _socialSignIn! ? 0 : 10,
                          ),
                          _socialSignIn!
                              ? Container()
                              : CustomTextField(
                                  autofillHints: [AutofillHints.newPassword],
                                  label: "Passwort",
                                  obscureText: true,
                                  preficIcon: Icon(
                                    Icons.vpn_key,
                                  ),
                                  textInputType: TextInputType.visiblePassword,
                                  onChanged: (text) {
                                    _password1 = text;
                                  },
                                  validator: Validate.password,
                                  textColor: _theme.colorScheme.onBackground,
                                  focusedColor: _theme.colorScheme.onBackground,
                                  activeColor: _theme.colorScheme.onBackground
                                      .withOpacity(.4),
                                ),
                          SizedBox(
                            height: _socialSignIn! ? 0 : 10,
                          ),
                          _socialSignIn!
                              ? Container()
                              : CustomTextField(
                                  autofillHints: [AutofillHints.newPassword],
                                  label: "Wiederholen",
                                  obscureText: true,
                                  preficIcon: Icon(
                                    Icons.vpn_key,
                                  ),
                                  textInputType: TextInputType.visiblePassword,
                                  onChanged: (text) {
                                    _password2 = text;
                                  },
                                  validator: Validate.password,
                                  textColor: _theme.colorScheme.onBackground,
                                  focusedColor: _theme.colorScheme.onBackground,
                                  activeColor: _theme.colorScheme.onBackground
                                      .withOpacity(.4),
                                ),
                          SizedBox(
                            height: 20,
                          ),
                          Theme(
                            data: context.theme.darkMode
                                ? ThemeData.dark()
                                : ThemeData.light(),
                            child: CheckboxListTile(
                              value: _acceptedAGBs,
                              onChanged: (check) {
                                setState(() {
                                  _acceptedAGBs = check;
                                });
                              },
                              activeColor: _theme.primaryColor,
                              checkColor: _theme.colorScheme.onPrimary,
                              title: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                      color: _theme.colorScheme.onBackground),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: 'Hiermit akzeptiere ich unsere '),
                                    TextSpan(
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                        ),
                                        text: 'Nutzungsbedingungen',
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            launchUrl(
                                                Constants.NUTZUNGSBEDINGUNGEN);
                                          }),
                                    TextSpan(text: " und "),
                                    TextSpan(
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                        ),
                                        text: 'Datenschutzbedingungen',
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            launchUrl(Constants.DATENSCHUTZ);
                                          }),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                                padding: const EdgeInsets.only(bottom: 18.0),
                                child: Builder(builder: (context) {
                                  return BigButton(
                                    onPressed:
                                        _um.status == Status.Authenticating ||
                                                _loading!
                                            ? null
                                            : () => _register(context),
                                    loading:
                                        _um.status == Status.Authenticating ||
                                            _loading!,
                                    label: "Registrieren",
                                    color: _theme.colorScheme.secondary,
                                  );
                                })),
                          )
                        ],
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void _register(BuildContext context) async {
    if (!_acceptedAGBs!) {
      _showSnackBar("Bitte akzeptiere die AGBs!", context);
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
    });

    ApiResult res;

    if (_socialSignIn!) {
      res = await _um.createSocialUserDocument(_username!, _phone);
    } else {
      if (_password1 != _password2) {
        _showSnackBar("Deine Passwörter stimmen nicht überein!", context);
        _um.status = Status.Unauthenticated;
        setState(() {
          _loading = false;
        });
        return;
      }

      User user = User(
          id: "",
          email: _email,
          name: _username!,
          phoneNumber: _phone,
          password: _password1);

      res = await _um.signUp(user, _profileImage, context);
    }

    if (res.hasError()) {
      _showSnackBar(res.message!, context);
      setState(() {
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
    });

    _um.firstSignIn = true;

    await _um.afterAuthentication();

    context.read<FirebaseAnalytics>().logSignUp(signUpMethod: "Email");
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => _socialSignIn!
                ? FindFriendsPage(
                    afterRegister: true,
                  )
                : VerifyEmailPage()));
  }

  void _showSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
