import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';

class CustomTextField extends StatelessWidget {
  final String hint, label;
  final Color activeColor, focusedColor, textColor;
  final Icon preficIcon;
  final TextInputType textInputType;
  final bool obscureText, autoCorrect;
  final Function(String) onChanged;
  final String Function(String) validator;
  final TextEditingController controller;
  final int maxLines, maxLength;

  CustomTextField(
      {this.controller,
      this.hint,
      this.label,
      this.maxLines = 1,
      this.maxLength,
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
        maxLines: maxLines,
        maxLength: maxLength,
        controller: controller,
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
                  color: activeColor.withOpacity(.5),
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
