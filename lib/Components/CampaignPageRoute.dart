import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Pages/CampaignPage.dart';

class CampaignPageRoute extends PageRouteBuilder {
  CampaignPageRoute(Campaign campaign)
      : super(
            pageBuilder: (c, animOne, animTwo) => CampaignPage(campaign),
            transitionDuration: Duration.zero,
            opaque: false);
}
