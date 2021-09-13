import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:one_d_m/helper/helper.dart';
import 'package:one_d_m/provider/donation_dialog_manager.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:provider/provider.dart';

enum DonationAddSubType { add, sub }

class DonationAddSubButton extends StatelessWidget {
  final DonationAddSubType type;

  const DonationAddSubButton(this.type);

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    bool isAdd = type == DonationAddSubType.add;
    Color buttonColor =
        isAdd ? _theme.colors.dark : Helper.hexToColor('#e2e2e2');

    return Consumer<DonationDialogManager>(builder: (context, ddm, child) {
      Color textColor = _theme.correctColorFor(buttonColor);
      return MaterialButton(
        clipBehavior: Clip.antiAlias,
        shape: CircleBorder(),
        color: buttonColor,
        disabledColor: buttonColor,
        elevation: 0,
        onPressed: ddm.loading
            ? null
            : isAdd
                ? ddm.add
                : ddm.sub,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isAdd
              ? Icon(Icons.add, color: textColor)
              : Text(
                  "-",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: textColor),
                ),
        ),
      );
    });
  }
}
