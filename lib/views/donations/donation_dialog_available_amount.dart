import 'package:flutter/material.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/provider/donation_dialog_manager.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:provider/provider.dart';

class DonationDialogAvailableAmount extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DonationDialogManager ddm = context.watch<DonationDialogManager>();
    ThemeManager _theme = context.read<ThemeManager>();

    if (ddm.fromCache)
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Lade verfügbare DVs...", style: _theme.textTheme.dark.caption),
          XMargin(12),
          LoadingIndicator(
            size: 8,
            strokeWidth: 1.8,
            color: _theme.colors.dark.withOpacity(.5),
          ),
        ],
      );

    return Text(
      _buildAvailableAmountText(ddm),
      style: _theme.textTheme.dark.bodyText2
          .copyWith(fontSize: 12, color: Colors.black54),
    );
  }

  String _buildAvailableAmountText(DonationDialogManager ddm) {
    if (ddm.initialLoading) return "0 DVs verfügbar";
    int amount = ddm.dr.userBalance ~/ ddm.dr.unit.value;

    return '$amount ${(amount == 1 ? ddm.dr.unit.singular : ddm.dr.unit.name) ?? 'DV'} verfügbar';
  }
}
