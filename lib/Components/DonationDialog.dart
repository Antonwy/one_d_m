import 'package:flutter/material.dart';
import 'package:one_d_m/Components/DontionDialogWidget.dart';

class DonationDialog {
  BuildContext context;
  OverlayState _overlay;
  Size _displaySize;
  OverlayEntry _entry;

  DonationDialog(this.context) {
    _overlay = Overlay.of(context);
    _displaySize = (context.findRenderObject() as RenderBox).size;
  }

  static DonationDialog of(BuildContext context) {
    return DonationDialog(context);
  }

  void show() {
    _entry = OverlayEntry(builder: (context) => DonationDialogWidget(close));
    _overlay.insert(_entry);
  }

  void close() {
    _entry.remove();
  }
}
