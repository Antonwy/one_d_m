import 'package:flutter/material.dart';

class ErrorText extends StatelessWidget {
  String message;
  TextStyle style;

  ErrorText(this.message, {this.style});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: style != null ? style : TextStyle(color: Colors.red),
    );
  }
}
