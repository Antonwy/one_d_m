import 'package:flutter/material.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:one_d_m/provider/donation_dialog_manager.dart';
import 'package:provider/provider.dart';

class DonationDialogAvailableAmount extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DonationDialogManager ddm = context.watch<DonationDialogManager>();
    ThemeData _theme = context.theme;

    if (ddm.fromCache!)
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Lade verfügbare DVs...", style: _theme.textTheme.caption),
          XMargin(12),
          LoadingIndicator(
            size: 8,
            strokeWidth: 1.8,
          ),
        ],
      );

    return Text(
      _buildAvailableAmountText(ddm),
      style:
          _theme.textTheme.bodyText2!.withOpacity(.54).copyWith(fontSize: 12),
    );
  }

  String _buildAvailableAmountText(DonationDialogManager ddm) {
    if (ddm.initialLoading!) return "0 DVs verfügbar";
    int amount = ddm.dr!.userBalance! ~/ ddm.dr!.unit.value!;

    return '$amount ${(amount == 1 ? ddm.dr!.unit.singular : ddm.dr!.unit.name) ?? 'DV'} verfügbar';
  }
}
