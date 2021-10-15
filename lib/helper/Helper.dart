import 'dart:math';
import 'package:flutter/material.dart';
import 'package:one_d_m/components/push_notification.dart';
import 'constants.dart';

class Helper {
  static Color? hexToColor(String? hexCode) {
    if (hexCode == null) return null;
    hexCode = hexCode.toUpperCase().replaceAll("#", "");
    if (hexCode.length == 6) {
      hexCode = "FF" + hexCode;
    }
    return Color(int.parse(hexCode, radix: 16));
  }

  static String colorToHex(Color color) {
    return '#' + color.value.toRadixString(16).substring(2);
  }

  static double mapValue(n, start1, stop1, start2, stop2) {
    if (start1 == 0 && stop1 == 0) return 0;
    return ((n - start1) / (stop1 - start1)) * (stop2 - start2) + start2;
  }

  static Offset getPositionFromKey(GlobalKey key) {
    if (key.currentContext == null) return Offset(0, 0);

    final RenderBox renderBox =
        key.currentContext!.findRenderObject() as RenderBox;
    final pos = renderBox.localToGlobal(Offset.zero);

    return pos;
  }

  static Offset getCenteredPositionFromKey(GlobalKey key) {
    Offset pos = Helper.getPositionFromKey(key);
    Size size = Helper.getSizeFromKey(key)!;
    return Offset(pos.dx + size.width / 2, pos.dy + size.height / 2);
  }

  static Size? getSizeFromKey(GlobalKey key) {
    if (key.currentContext == null) return null;

    final RenderBox containerRenderBox =
        key.currentContext!.findRenderObject() as RenderBox;
    return containerRenderBox.size;
  }

  static double getTextWidth(String text,
      {TextStyle style = const TextStyle()}) {
    TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr);
    textPainter.layout();
    return textPainter.width;
  }

  static String getDate(DateTime date) {
    return "${date.day < 10 ? "0${date.day}" : date.day}.${date.month < 10 ? "0${date.month}" : date.month}.${date.year}";
  }

  static Future<bool?> showAlert(BuildContext context, String message,
      {String title = "Error"}) {
    return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Constants.radius)),
              title: Text(title),
              content: Text(
                message,
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "OKAY",
                    ))
              ],
            ));
  }

  static Future<bool?> showWarningAlert(BuildContext context, String message,
      {String title = "Error", String acceptButton = "OKAY"}) {
    return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Constants.radius)),
              title: Text(title),
              content: Text(
                message,
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop<bool>(context, false),
                    child: Text(
                      "ABBRECHEN",
                    )),
                TextButton(
                    onPressed: () => Navigator.pop<bool>(context, true),
                    child: Text(
                      acceptButton,
                      style: TextStyle(color: Colors.red),
                    )),
              ],
            ));
  }

  static num degreesToRads(num deg) {
    return (deg * pi) / 180.0;
  }

  static Future<void> showConnectionSnackBar(BuildContext context) {
    return ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Stelle eine Verbindung her!")))
        .closed;
  }

  static Future<void> showConnectionPushNotification(BuildContext context) {
    NotificationContent content = NotificationContent(
        title: "Keine Verbindung",
        body: "Stelle eine Verbindung zum Internet her.",
        icon: Icons.wifi_off);
    return PushNotification.of(context).show(content);
  }

  static List<T> castList<T>(List? list) {
    if (list == null) return <T>[];
    return List<T>.from(list);
  }

  static List<Map<String, dynamic>> castJson(List? list) {
    if (list == null) return <Map<String, dynamic>>[];
    return List.from(list.map((e) {
      return Map<String, dynamic>.from(e);
    }));
  }
}
