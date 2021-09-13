import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lottie/lottie.dart';
import 'package:number_slide_animation/number_slide_animation.dart';
import 'package:one_d_m/components/chart/circle_painter.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/helper/database_service.dart';
import 'package:one_d_m/models/campaign_models/base_campaign.dart';
import 'package:one_d_m/models/campaign_models/campaign.dart';
import 'package:one_d_m/models/user.dart';
import 'package:one_d_m/provider/donation_dialog_manager.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/provider/user_manager.dart';
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
