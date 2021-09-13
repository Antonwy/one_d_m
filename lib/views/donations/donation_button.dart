import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:one_d_m/components/discovery_holder.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/helper/database_service.dart';
import 'package:one_d_m/helper/helper.dart';
import 'package:one_d_m/models/campaign_models/campaign.dart';
import 'package:one_d_m/models/donation.dart';
import 'package:one_d_m/models/user.dart';
import 'package:one_d_m/provider/donation_dialog_manager.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:provider/provider.dart';

class DonationButton extends StatelessWidget {
  ThemeManager _theme;
  DonationDialogManager ddm;
  BuildContext context;

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    ddm = context.watch<DonationDialogManager>();
    this.context = context;

    return DiscoveryHolder.supportButton(
      tapTarget: Icon(
        Icons.euro,
        color: _theme.colors.contrast,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0),
        child: OfflineBuilder(
            child: Container(),
            connectivityBuilder: (c, connection, child) {
              bool connected = connection != ConnectivityResult.none;
              Color btnColor =
                  ddm.dr?.sessionPrimaryColor ?? _theme.colors.dark;
              Color textColor = _theme.correctColorFor(btnColor);

              bool active = ddm.amount != null &&
                  ddm.amount != 0 &&
                  ddm.amount <= (ddm.dr?.userBalance ?? 0);

              return MaterialButton(
                minWidth: 170,
                height: 50,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Constants.radius)),
                elevation: 0,
                color: btnColor,
                disabledColor: Colors.grey,
                onPressed: active
                    ? connected
                        ? () => ddm.donate()
                        : () {
                            Helper.showConnectionSnackBar(context);
                          }
                    : null,
                child: ddm.loading
                    ? LoadingIndicator(color: textColor, size: 18)
                    : Text(
                        "Support!",
                        style: _theme.textTheme
                            .withColor(active ? textColor : Colors.white)
                            .headline5
                            .copyWith(
                                fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              );
            }),
      ),
    );
  }
}
