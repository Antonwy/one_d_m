import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String? hint, label;
  final Color? activeColor, focusedColor, textColor;
  final Icon? preficIcon;
  final TextInputType textInputType;
  final bool obscureText, autoCorrect;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final int? maxLines, maxLength;
  final List<TextInputFormatter>? inputFormatter;
  final List<String> autofillHints;

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
      this.validator,
      this.inputFormatter,
      this.autofillHints = const []});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: focusedColor,
        hintColor: activeColor,
        errorColor: Colors.red,
      ),
      child: AnimatedSize(
        duration: Duration(milliseconds: 500),
        curve: Curves.fastLinearToSlowEaseIn,
        alignment: Alignment.topCenter,
        child: TextFormField(
          autofillHints: autofillHints,
          maxLines: maxLines,
          maxLength: maxLength,
          controller: controller,
          autocorrect: autoCorrect,
          cursorColor: focusedColor,
          onChanged: onChanged,
          validator: validator,
          inputFormatters: inputFormatter ?? [],
          keyboardType: textInputType,
          obscureText: obscureText,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            prefixIcon: preficIcon == null
                ? null
                : Icon(
                    preficIcon!.icon,
                    color: activeColor!.withOpacity(.5),
                  ),
            border: OutlineInputBorder(),
            focusColor: Colors.red,
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: activeColor!)),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: focusedColor!, width: 2),
            ),
            hintText: hint,
            labelStyle: TextStyle(color: activeColor),
            labelText: label,
          ),
        ),
      ),
    );
  }
}

class UserNameFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.trim().toLowerCase(),
      selection: newValue.selection,
    );
  }
}
