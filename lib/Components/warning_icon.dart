import 'package:flutter/material.dart';

class WarningIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.red.withOpacity(.15),
      shape: CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Icon(Icons.warning, color: Colors.red),
      ),
    );
  }
}
