import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:one_d_m/provider/donation_dialog_manager.dart';
import 'package:one_d_m/views/donations/donation_thank_you.dart';
import 'package:provider/provider.dart';

class DonationAnimationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DonationDialogManager>(builder: (context, ddm, child) {
      return AnimatedOpacity(
        opacity: ddm.showAnimation ? 1 : 0,
        duration: Duration(milliseconds: 250),
        child: AnimatedSwitcher(
            duration: Duration(seconds: 1),
            child: !ddm.showThankYou
                ? Lottie.asset('assets/anim/anim_start.json', repeat: false,
                    onLoaded: (composition) {
                    HapticFeedback.heavyImpact();
                    Timer(Duration(milliseconds: 1250), () {
                      ddm.showThankYou = true;
                    });
                  })
                : DonationThankYou()),
      );
    });
  }
}
