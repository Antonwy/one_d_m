import 'package:flutter/material.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
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
  late ThemeData _theme;

  String? _email;

  GlobalKey<FormState> _formKey = GlobalKey();

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Constants.radius)),
      title: Text("Email eingeben"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Um dein Passwort zurückzusetzen brauchen wir deine Email!",
            style: _theme.textTheme.caption,
          ),
          SizedBox(
            height: 12,
          ),
          Form(
            key: _formKey,
            child: CustomTextField(
              label: "Email",
              hint: "tester@gmail.com",
              textInputType: TextInputType.emailAddress,
              autoCorrect: false,
              textColor: _theme.colorScheme.onBackground,
              focusedColor: _theme.colorScheme.onBackground,
              activeColor: _theme.colorScheme.onBackground.withOpacity(.6),
              onChanged: (text) {
                _email = text.toLowerCase();
              },
              validator: Validate.email,
            ),
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context, null);
          },
          child: Text("Abbrechen"),
        ),
        Consumer<UserManager>(
          builder: (context, um, child) => TextButton(
            style: TextButton.styleFrom(),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  _loading = true;
                });
                try {
                  // await um.resetPassword();
                  await Future.delayed(Duration(seconds: 2));
                } catch (e) {
                  print(e);
                  setState(() {
                    _loading = false;
                  });
                }
                Navigator.pop(context, 'Email wurde an "$_email" geschickt!');
              }
            },
            child: AnimatedSize(
              duration: Duration(milliseconds: 250),
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                      duration: Duration(milliseconds: 250),
                      child: _loading
                          ? LoadingIndicator(
                              size: 12,
                              strokeWidth: 2,
                              color: context.theme.errorColor)
                          : Container()),
                  if (_loading) XMargin(12),
                  Text("Zurücksetzen",
                      style: TextStyle(color: context.theme.errorColor))
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
