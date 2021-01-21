import 'package:catcher/model/platform_type.dart';
import 'package:catcher/model/report.dart';
import 'package:catcher/model/report_mode.dart';
import 'package:catcher/utils/catcher_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';

class CustomReportMode extends ReportMode {
  @override
  void requestAction(Report report, BuildContext context) {
    _showDialog(report, context);
  }

  Future _showDialog(Report report, BuildContext context) async {
    await Future<void>.delayed(Duration.zero);
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildMaterialDialog(report, context));
  }

  Widget _buildMaterialDialog(Report report, BuildContext context) {
    return AlertDialog(
      title: Text(localizationOptions.dialogReportModeTitle),
      content: Text(localizationOptions.dialogReportModeDescription),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      actions: <Widget>[
        FlatButton(
          textColor: ColorTheme.orange,
          child: Text(localizationOptions.dialogReportModeAccept),
          onPressed: () => _onAcceptReportClicked(context, report),
        ),
        FlatButton(
          textColor: ColorTheme.blue,
          child: Text(localizationOptions.dialogReportModeCancel),
          onPressed: () => _onCancelReportClicked(context, report),
        ),
      ],
    );
  }

  void _onAcceptReportClicked(BuildContext context, Report report) {
    super.onActionConfirmed(report);
    _pop(context);
  }

  void _onCancelReportClicked(BuildContext context, Report report) {
    super.onActionRejected(report);
    _pop(context);
  }

  void _pop(BuildContext context) =>
      Navigator.popUntil(context, (route) => route.isFirst);

  @override
  bool isContextRequired() {
    return true;
  }

  @override
  List<PlatformType> getSupportedPlatforms() =>
      [PlatformType.Web, PlatformType.Android, PlatformType.iOS];
}
