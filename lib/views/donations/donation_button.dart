import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:one_d_m/components/big_button.dart';
import 'package:one_d_m/components/discovery_holder.dart';
import 'package:one_d_m/helper/helper.dart';
import 'package:one_d_m/provider/donation_dialog_manager.dart';
import 'package:provider/provider.dart';

class DonationButton extends StatelessWidget {
  late ThemeData _theme;
  late DonationDialogManager ddm;
  BuildContext? context;

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    ddm = context.watch<DonationDialogManager>();
    this.context = context;

    return DiscoveryHolder.supportButton(
      tapTarget: Icon(
        Icons.euro,
        color: _theme.colorScheme.onPrimary,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.0, 0, 12, 12),
        child: OfflineBuilder(
            child: Container(),
            connectivityBuilder: (c, connection, child) {
              bool connected = connection != ConnectivityResult.none;
              Color btnColor =
                  ddm.dr?.sessionPrimaryColor ?? _theme.colorScheme.secondary;

              bool active = ddm.amount != null &&
                  ddm.amount != 0 &&
                  ddm.amount! <= (ddm.dr?.userBalance ?? 0);

              return Container(
                width: 150,
                child: BigButton(
                  color: btnColor,
                  onPressed: connected
                      ? () {
                          ddm.donate();
                        }
                      : () {
                          Helper.showConnectionSnackBar(context);
                        },
                  label: "Support!",
                  fontSize: 16,
                  loading: ddm.loading!,
                ),
              );
            }),
      ),
    );
  }
}
