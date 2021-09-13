import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/helper/helper.dart';
import 'package:one_d_m/models/campaign_models/base_campaign.dart';
import 'package:one_d_m/models/session_models/base_session.dart';
import 'package:one_d_m/models/session_models/preview_session.dart';
import 'package:one_d_m/models/session_models/session.dart';
import 'package:one_d_m/models/user.dart';

class UploadableSession {
  final BaseCampaign campaign;
  final List<User> members;
  final String name, description, creatorId;
  String imgUrl, id;
  final int donationGoal;
  final File image;
  final Color primaryColor, secondaryColor;

  UploadableSession({
    this.id,
    this.name,
    this.description,
    this.donationGoal,
    this.campaign,
    this.members,
    this.image,
    this.imgUrl,
    this.primaryColor,
    this.secondaryColor,
    this.creatorId,
  });

  Map<String, dynamic> toMap() {
    return {
      BaseSession.CAMPAIGN_ID: campaign.id,
      BaseSession.PRIMARY_COLOR: Helper.colorToHex(primaryColor),
      BaseSession.SECONDARY_COLOR: Helper.colorToHex(secondaryColor),
      BaseSession.SESSION_NAME: name,
      BaseSession.ID: id,
      BaseSession.DONATION_GOAL: donationGoal,
      BaseSession.SESSION_DESCRIPTION: description,
      BaseSession.CREATOR_ID: creatorId,
      BaseSession.IMG_URL: imgUrl,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    Map<String, dynamic> map = {
      BaseSession.PRIMARY_COLOR: Helper.colorToHex(primaryColor),
      BaseSession.SECONDARY_COLOR: Helper.colorToHex(secondaryColor),
      BaseSession.SESSION_NAME: name,
      BaseSession.DONATION_GOAL: donationGoal,
      BaseSession.SESSION_DESCRIPTION: description,
    };

    if (imgUrl != null) map[BaseSession.IMG_URL] = imgUrl;
    return map;
  }

  BaseSession get baseSession => PreviewSession(
      id: "no-id",
      campaignId: campaign.id,
      name: name,
      donationGoal: donationGoal,
      donationGoalCurrent: 0,
      description: description,
      creatorId: creatorId,
      secondaryColor: secondaryColor,
      primaryColor: primaryColor);
}
