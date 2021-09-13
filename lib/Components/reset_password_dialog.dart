import 'package:flutter/material.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/helper/validate.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:provider/provider.dart';

import 'custom_text_field.dart';

class ResetPasswordDialog extends StatefulWidget {
  @override
  _ResetPasswordDialogState createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  TextTheme _textTheme;

  String _email;

  GlobalKey<FormState> _formKey = GlobalKey();

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Constants.radius)),
      title: Text("Passwort zurücksetzen"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Email eingeben",
            style: _textTheme.headline6,
          ),
          Text(
            "Um dein Passwort zurückzusetzen brauchen wir deine Email!",
            style: _textTheme.caption,
          ),
          SizedBox(
            height: 10,
          ),
          Form(
            key: _formKey,
            child: CustomTextField(
              label: "Email",
              hint: "tester@gmail.com",
              textInputType: TextInputType.emailAddress,
              textColor: ColorTheme.blue,
              focusedColor: ColorTheme.blue,
              activeColor: ColorTheme.blue.withOpacity(.6),
              onChanged: (text) {
                _email = text.toLowerCase();
              },
              validator: Validate.email,
            ),
          )
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.pop(context, null);
          },
          child: Text("ABBRECHEN"),
          textColor: ColorTheme.blue,
        ),
        Consumer<UserManager>(
          builder: (context, um, child) => FlatButton(
            onPressed: () {
              if (_formKey.currentState.validate()) {
                setState(() {
                  _loading = true;
                });
                um.resetPassword();
                Navigator.pop(context, _email);
              }
            },
            child: _loading
                ? Container(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(ColorTheme.orange),
                    ),
                  )
                : Text("ZURÜCKSETZEN"),
            textColor: ColorTheme.orange,
          ),
        ),
      ],
    );
  }
}
