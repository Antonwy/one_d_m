import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:one_d_m/Components/CustomTextField.dart';
import 'package:one_d_m/Helper/API/ApiResult.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/ContactManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Helper/Validate.dart';
import 'package:one_d_m/Pages/VerifyEmailPage.dart';
import 'package:provider/provider.dart';

import 'HomePage/HomePage.dart';

class NewRegisterPage extends StatefulWidget {
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
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;
    _um = Provider.of<UserManager>(context);

    if (_um.status == Status.Authenticated)
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.push(context, MaterialPageRoute(builder: (c) => HomePage()));
      });

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ColorTheme.blue,
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: ColorTheme.blue,
        elevation: 0,
        title: Text("Registrieren"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: SvgPicture.asset(
                    'assets/images/register.svg',
                    height: 200,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: <Widget>[
                    Container(
                      width: 70,
                      height: 70,
                      child: Material(
                        shape: CircleBorder(),
                        color: ColorTheme.red,
                        elevation: 10,
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                            onTap: () async {
                              _profileImage = await ImagePicker.pickImage(
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
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                CustomTextField(
                  label: "Email",
                  hint: "test@gmail.com",
                  preficIcon: Icon(Icons.email),
                  textInputType: TextInputType.emailAddress,
                  onChanged: (text) {
                    _email = text.toLowerCase();
                  },
                  validator: Validate.email,
                  focusedColor: ColorTheme.red,
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
                  onChanged: (text) {
                    _username = text;
                  },
                  validator: Validate.username,
                  focusedColor: ColorTheme.red,
                  activeColor: ColorTheme.white.withOpacity(.4),
                ),
                SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  label: "Telefonnummer (optional)",
                  preficIcon: Icon(
                    Icons.phone,
                  ),
                  textInputType: TextInputType.phone,
                  onChanged: (text) {
                    _phone = text;
                  },
                  validator: Validate.telephone,
                  focusedColor: ColorTheme.red,
                  activeColor: ColorTheme.white.withOpacity(.4),
                ),
                SizedBox(
                  height: 10,
                ),
                CustomTextField(
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
                  focusedColor: ColorTheme.red,
                  activeColor: ColorTheme.white.withOpacity(.4),
                ),
                SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  label: "Passwort",
                  obscureText: true,
                  preficIcon: Icon(
                    Icons.vpn_key,
                  ),
                  textInputType: TextInputType.visiblePassword,
                  onChanged: (text) {
                    _password2 = text;
                  },
                  validator: Validate.password,
                  focusedColor: ColorTheme.red,
                  activeColor: ColorTheme.white.withOpacity(.4),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: FloatingActionButton.extended(
                    onPressed: _um.status == Status.Authenticating || _loading
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
                              valueColor: AlwaysStoppedAnimation(Colors.white),
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
        ),
      ),
    );
  }

  void _register() async {
    if (!_formKey.currentState.validate()) return;
    if (_password1 != _password2) {
      _showSnackBar("Deine Passwörter stimmen nicht überein!");
      return;
    }

    User user = User(
        email: _email,
        name: _username,
        phoneNumber: _phone,
        password: _password1);

    ApiResult res = await _um.signUp(user, _profileImage);

    if (res.hasError()) {
      _showSnackBar(res.message);
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

    Navigator.push(
        context, MaterialPageRoute(builder: (c) => VerifyEmailPage()));
  }

  void _showSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }
}
