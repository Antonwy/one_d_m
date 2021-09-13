import 'package:flutter/material.dart';
import 'package:one_d_m/models/donation_unit.dart';
import 'package:one_d_m/models/session_models/base_session.dart';
import 'package:one_d_m/models/session_models/uploadable_session.dart';
import 'package:one_d_m/provider/sessions_manager.dart';

class PreviewSession extends BaseSession {
  final UploadableSession uploadableSession;

  PreviewSession(
      {String id,
      String campaignId,
      String name,
      int donationGoal,
      int donationGoalCurrent,
      DonationUnit donationUnit,
      String description,
      String creatorId,
      Color secondaryColor,
      Color primaryColor,
      String imgUrl,
      this.uploadableSession})
      : super(
            id: id,
            campaignId: campaignId,
            name: name,
            amount: 0,
            donationGoal: donationGoal,
            donationUnit: DonationUnit(),
            description: description ?? "",
            creatorId: creatorId,
            imgUrl: imgUrl,
            secondaryColor: secondaryColor,
            primaryColor: primaryColor,
            isCertified: false);

  @override
  BaseSessionManager manager(String uid) =>
      PreviewSessionManager(this, uid: uid);
}
