import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:one_d_m/Components/CustomTextField.dart';
import 'package:one_d_m/Helper/API/ApiResult.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/ContactManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Helper/Validate.dart';
import 'package:one_d_m/Pages/FindFriendsPage.dart';
import 'package:one_d_m/Pages/VerifyEmailPage.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class NewRegisterPage extends StatefulWidget {
  bool socialSignIn;

  NewRegisterPage({this.socialSignIn = false});

  @override
  _NewRegisterPageState createState() => _NewRegisterPageState();
}

class _NewRegisterPageState extends State<NewRegisterPage> {
  UserManager _um;

  TextTheme _textTheme;

  File _profileImage;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  GlobalKey<FormState> _formKey = GlobalKey();

  String _email, _username, _phone, _password1, _password2;
  bool _loading = false, _socialSignIn, _acceptedAGBs = false;

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;
    _um = Provider.of<UserManager>(context);
    _socialSignIn = widget.socialSignIn;

    if (_um.status == Status.Authenticated)
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.pop(context);
      });

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ColorTheme.blue,
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              brightness: Brightness.dark,
              backgroundColor: ColorTheme.blue,
              elevation: 0,
              title: Text(_socialSignIn ? "Weitere Daten" : "Registrieren"),
              leading: BackButton(
                onPressed: () {
                  _um.status = Status.Unauthenticated;
                  Navigator.pop(context);
                },
              ),
            ),
            SliverFillRemaining(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _socialSignIn
                        ? AutoSizeText(
                            "Zum Beenden deiner Registrierung brauchen wir noch ein paar Daten!",
                            maxLines: 2,
                            style: _textTheme.bodyText1
                                .copyWith(color: ColorTheme.whiteBlue))
                        : Row(
                            children: <Widget>[
                              Container(
                                width: 70,
                                height: 70,
                                child: Material(
                                  shape: CircleBorder(),
                                  color: ColorTheme.appGrey,
                                  elevation: 10,
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                      onTap: () async {
                                        _profileImage =
                                            await ImagePicker.pickImage(
                                                source: ImageSource.gallery);
                                        setState(() {});
                                      },
                                      child: _profileImage != null
                                          ? Image.file(
                                              _profileImage,
                                              fit: BoxFit.cover,
                                            )
                                          : Icon(Icons.add)),
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "Profilbild",
                                      style: _textTheme.headline6
                                          .copyWith(color: Colors.white),
                                    ),
                                    Text(
                                      "Wenn du magst, kannst du hier ein Bild von dir hochladen.",
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                    SizedBox(
                      height: _socialSignIn ? 0 : 20,
                    ),
                    _socialSignIn
                        ? Container()
                        : CustomTextField(
                            label: "Email",
                            hint: "test@gmail.com",
                            preficIcon: Icon(Icons.email),
                            textInputType: TextInputType.emailAddress,
                            autoCorrect: false,
                            onChanged: (text) {
                              _email = text.trim().toLowerCase();
                            },
                            validator: Validate.email,
                            focusedColor: ColorTheme.appGrey,
                            activeColor: ColorTheme.white.withOpacity(.4),
                          ),
                    SizedBox(
                      height: 10,
                    ),
                    CustomTextField(
                      label: "Nutzername",
                      preficIcon: Icon(
                        Icons.person,
                      ),
                      textInputType: TextInputType.text,
                      autoCorrect: false,
                      inputFormatter: [UserNameFormatter()],
                      onChanged: (text) {
                        _username = text.trim();
                      },
                      maxLength: 15,
                      validator: Validate.username,
                      focusedColor: ColorTheme.appGrey,
                      activeColor: ColorTheme.white.withOpacity(.4),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    !_socialSignIn ||
                            (_socialSignIn && _um.fireUser?.phoneNumber == null)
                        ? CustomTextField(
                            label: "Telefonnummer",
                            preficIcon: Icon(
                              Icons.phone,
                            ),
                            textInputType: TextInputType.phone,
                            onChanged: (text) {
                              _phone = text;
                            },
                            validator: Validate.telephone,
                            focusedColor: ColorTheme.appGrey,
                            activeColor: ColorTheme.white.withOpacity(.4),
                          )
                        : Container(),
                    SizedBox(
                      height: _socialSignIn ? 0 : 10,
                    ),
                    _socialSignIn
                        ? Container()
                        : CustomTextField(
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
                            focusedColor: ColorTheme.appGrey,
                            activeColor: ColorTheme.white.withOpacity(.4),
                          ),
                    SizedBox(
                      height: _socialSignIn ? 0 : 10,
                    ),
                    _socialSignIn
                        ? Container()
                        : CustomTextField(
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
                            focusedColor: ColorTheme.appGrey,
                            activeColor: ColorTheme.white.withOpacity(.4),
                          ),
                    SizedBox(
                      height: 20,
                    ),
                    Theme(
                      data: ThemeData.dark(),
                      child: CheckboxListTile(
                        value: _acceptedAGBs,
                        onChanged: (check) {
                          setState(() {
                            _acceptedAGBs = check;
                          });
                        },
                        activeColor: ColorTheme.appGrey,
                        checkColor: ColorTheme.blue,
                        title: RichText(
                          text: TextSpan(
                            style: TextStyle(color: ColorTheme.whiteBlue),
                            children: <TextSpan>[
                              TextSpan(text: 'Hiermit akzeptiere ich unsere '),
                              TextSpan(
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: ColorTheme.appGrey),
                                  text: 'Nutzungsbedingungen',
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      launchUrl(Constants.NUTZUNGSBEDINGUNGEN);
                                    }),
                              TextSpan(text: " und "),
                              TextSpan(
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: ColorTheme.appGrey),
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18.0),
                      child: FloatingActionButton.extended(
                        onPressed:
                            _um.status == Status.Authenticating || _loading
                                ? null
                                : _register,
                        elevation: 0,
                        highlightElevation: 7,
                        splashColor: ColorTheme.blue,
                        hoverColor: ColorTheme.blue,
                        focusColor: ColorTheme.blue,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 2, color: Colors.white),
                          borderRadius: BorderRadius.circular(23),
                        ),
                        backgroundColor: ColorTheme.blue,
                        icon: _um.status == Status.Authenticating || _loading
                            ? Container(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : Icon(
                                Icons.done,
                              ),
                        label: Text(
                          "Registrieren",
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void _register() async {
    if (!_formKey.currentState.validate()) return;
    setState(() {
      _loading = true;
    });

    ApiResult res;

    if (_socialSignIn) {
      res = await _um.createSocialUserDocument(_username, _phone);
    } else {
      if (_password1 != _password2) {
        _um.status = Status.Unauthenticated;
        _showSnackBar("Deine Passwörter stimmen nicht überein!");
        return;
      }

      User user = User(
          email: _email,
          name: _username,
          phoneNumber: _phone,
          password: _password1);

      res = await _um.signUp(user, _profileImage);
    }

    if (res.hasError()) {
      _showSnackBar(res.message);
      setState(() {
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      ContactManager.uploadPhoneNumbers(await ContactManager.phoneNumberList());
    } on PermissionException catch (e) {
      print(e);
    }

    _um.firstSignIn = true;

    await _um.afterAuthentication();

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => _socialSignIn
                ? FindFriendsPage(
                    afterRegister: true,
                  )
                : VerifyEmailPage()));
  }

  void _showSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }
}
