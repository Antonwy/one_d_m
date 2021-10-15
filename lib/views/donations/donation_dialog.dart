import 'dart:async';
import 'dart:math';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:one_d_m/components/discovery_holder.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/components/replace_text.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/helper/currency.dart';
import 'package:one_d_m/models/campaign_models/campaign.dart';
import 'package:one_d_m/models/donation.dart';
import 'package:one_d_m/models/session_models/session.dart';
import 'package:one_d_m/models/user.dart';
import 'package:one_d_m/provider/donation_dialog_manager.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/views/donations/donation_add_sub_button.dart';
import 'package:one_d_m/views/donations/donation_button.dart';
import 'package:one_d_m/views/donations/donation_dialog_available_amount.dart';
import 'package:one_d_m/views/donations/donation_dialog_heading.dart';
import 'package:one_d_m/views/donations/donation_dialog_holder.dart';
import 'package:provider/provider.dart';

class DonationDialog extends StatefulWidget {
  final Function? close;
  final Campaign? campaign;
  final Session? session;
  final User? user;
  final int defaultSelectedAmount;
  final String? sessionId;
  final String? uid, cid;

  DonationDialog({
    this.cid,
    this.uid,
    this.campaign,
    this.session,
    this.user,
    this.sessionId,
    this.close,
    this.defaultSelectedAmount = 0,
  });

  static Future<Donation?> show(BuildContext context,
      {String? campaignId,
      String? sessionId,
      List<String>? donationEffects = const []}) async {
    return showMaterialModalBottomSheet<Donation>(
        context: context,
        backgroundColor: context.theme.cardColor,
        builder: (context) => DonationDialogHolder(
            campaignId: campaignId,
            sessionId: sessionId,
            donationEffects: donationEffects),
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(Constants.radius))));
  }

  @override
  _DonationDialogState createState() => _DonationDialogState();
}

class _DonationDialogState extends State<DonationDialog>
    with SingleTickerProviderStateMixin {
  late ThemeData _theme;

  @override
  void initState() {
    context
        .read<FirebaseAnalytics>()
        .setCurrentScreen(screenName: "Donation Dialog");

    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      FeatureDiscovery.discoverFeatures(
          context, DiscoveryHolder.donationDialogFeatures);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        DonationDialogHeading(),
        Expanded(child: Container()),
        Consumer<DonationDialogManager>(
          builder: (context, ddm, child) {
            String amount = _buildAmountText(ddm);
            return AnimatedSwitcher(
              duration: Duration(milliseconds: 250),
              child: Text(
                amount,
                key: Key(amount),
                style: _theme.textTheme.bodyText1!
                    .copyWith(fontSize: 21, fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
        const YMargin(5),
        DonationDialogAvailableAmount(),
        Row(
          children: [
            Expanded(
                flex: 1,
                child: DiscoveryHolder.donationSub(
                    tapTarget: Text(
                      "-",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                          color: _theme.colorScheme.onPrimary),
                    ),
                    child: DonationAddSubButton(DonationAddSubType.sub))),
            Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Container(
                      color: _theme.primaryColor.withOpacity(.1),
                      height: 1,
                    ),
                  ],
                )),
            Expanded(
                flex: 1,
                child: DiscoveryHolder.donationAdd(
                    tapTarget: Icon(
                      Icons.add,
                      color: _theme.colorScheme.onPrimary,
                    ),
                    child: DonationAddSubButton(DonationAddSubType.add)))
          ],
        ),
        Expanded(child: Container()),
        Consumer<DonationDialogManager>(builder: (context, ddm, child) {
          if (ddm.initialLoading! || (ddm.dr?.donationEffects?.isEmpty ?? true))
            return Container();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Align(
              alignment: Alignment.center,
              child: Builder(builder: (context) {
                List<String> dEffects = ddm.dr!.donationEffects ?? [];
                String effect = dEffects.isEmpty
                    ? ""
                    : dEffects[new Random(42).nextInt(dEffects.length)];
                return ReplaceText(
                  text: effect,
                  textAlign: TextAlign.center,
                  value: Currency((ddm.amount!.toInt() * 5)).value(),
                  style: _theme.textTheme.bodyText2!.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                );
              }),
            ),
          );
        }),
        const YMargin(20),
        DonationButton(),
        YMargin(18),
      ],
    );
  }

  String _buildAmountText(DonationDialogManager ddm) {
    if (ddm.initialLoading!) return "Laden...";

    int amount = ddm.amount! ~/ ddm.dr!.unit.value;

    return '$amount ${(amount == 1 ? ddm.dr!.unit.singular : ddm.dr!.unit.name)}';
  }
}

class InfoCardWidget extends StatelessWidget {
  final Widget? childWidget;
  final bool? isDark;

  const InfoCardWidget({Key? key, this.childWidget, this.isDark})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    BaseTheme? _bTheme = ThemeManager.of(context).colors;
    return Container(
      height: 70,
      width: 158,
      margin: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 0,
        color: isDark! ? _bTheme.dark : _bTheme.contrast,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: childWidget,
        ),
      ),
    );
  }
}
