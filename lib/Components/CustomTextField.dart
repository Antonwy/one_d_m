import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';

class CustomTextField extends StatelessWidget {
  String hint, label;
  Color activeColor, focusedColor, textColor;
  Icon preficIcon;
  TextInputType textInputType;
  bool obscureText, autoCorrect;
  Function(String) onChanged;
  String Function(String) validator;

  CustomTextField(
      {this.hint,
      this.label,
      this.preficIcon,
      this.obscureText = false,
      this.textInputType = TextInputType.text,
      this.activeColor = Colors.black26,
      this.focusedColor = Colors.black,
      this.textColor = Colors.white,
      this.onChanged,
      this.autoCorrect = true,
      this.validator});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: focusedColor,
        hintColor: activeColor,
        errorColor: Colors.red,
      ),
      child: TextFormField(
        autocorrect: autoCorrect,
        cursorColor: focusedColor,
        onChanged: onChanged,
        validator: validator,
        keyboardType: textInputType,
        obscureText: obscureText,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          prefixIcon: preficIcon == null
              ? null
              : Icon(
                  preficIcon.icon,
                  color: ColorTheme.whiteBlue.withOpacity(.5),
                ),
          border: OutlineInputBorder(),
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: activeColor)),
          hintText: hint,
          labelStyle: TextStyle(color: activeColor),
          labelText: label,
        ),
      ),
    );
  }
}
