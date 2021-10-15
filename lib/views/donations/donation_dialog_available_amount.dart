import 'package:flutter/material.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:one_d_m/provider/donation_dialog_manager.dart';
import 'package:provider/provider.dart';

class DonationDialogAvailableAmount extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DonationDialogManager ddm = context.watch<DonationDialogManager>();
    ThemeData _theme = context.theme;

    String text = ddm.fromCache!
        ? "Lade verfügbare DVs..."
        : _buildAvailableAmountText(ddm);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: _theme.textTheme.caption,
        ),
        AnimatedSize(
          duration: Duration(milliseconds: 500),
          curve: Curves.fastLinearToSlowEaseIn,
          child: ddm.fromCache!
              ? Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: LoadingIndicator(
                    size: 8,
                    strokeWidth: 1.8,
                  ),
                )
              : SizedBox.shrink(),
        ),
      ],
    );
  }

  String _buildAvailableAmountText(DonationDialogManager ddm) {
    if (ddm.initialLoading!) return "0 DVs verfügbar";
    int amount = ddm.dr!.userBalance! ~/ ddm.dr!.unit.value;

    return '$amount ${(amount == 1 ? ddm.dr!.unit.singular : ddm.dr!.unit.name)} verfügbar';
  }
}
