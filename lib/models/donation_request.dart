import 'package:flutter/material.dart';
import 'package:one_d_m/helper/helper.dart';
import 'package:one_d_m/models/donation_unit.dart';

class DonationRequest {
  final String? campaignBlurHash,
      campaignImageUrl,
      campaignShortDescription,
      campaignShortVideoUrl,
      campaignName,
      campaignId,
      animationUrl,
      userBlurHash,
      userImageUrl,
      username,
      userId,
      organizationImageUrl,
      organizationName,
      organizationId,
      sessionBlurHash,
      sessionImageUrl,
      sessionName,
      sessionId;
  int? campaignCategoryId, userBalance, sessionDonationGoal;
  final List<String>? donationEffects, campaignEffects, tags;
  final DonationUnit unit;
  final bool? sessionIsCertified;
  final Color? sessionPrimaryColor, sessionSecondaryColor;

  DonationRequest.fromJson(Map<String, dynamic> json)
      : campaignBlurHash = json['campaign_blur_hash'],
        campaignCategoryId = json['campaign_category_id'],
        campaignImageUrl = json['campaign_image_url'],
        campaignShortDescription = json['campaign_short_description'],
        campaignShortVideoUrl = json['campaign_short_video_url'],
        campaignName = json['campaign_name'],
        campaignId = json['campaign_id'],
        animationUrl = json['animation_url'],
        donationEffects = json['donation_effects']?.cast<String>(),
        campaignEffects = json['campaign_effects']?.cast<String>(),
        tags = json['tags']?.cast<String>(),
        userBlurHash = json['user_blur_hash'],
        userImageUrl = json['user_image_url'],
        username = json['username'],
        userBalance = json['user_balance'] ?? 0,
        userId = json['user_id'],
        unit = DonationUnit.fromMap(json),
        organizationId = json['organization_id'],
        organizationName = json['organization_name'],
        organizationImageUrl = json['organization_image_url'],
        sessionBlurHash = json['session_blur_hash'],
        sessionDonationGoal = json['session_donation_goal'],
        sessionImageUrl = json['session_image_url'],
        sessionIsCertified = json['session_is_certified'],
        sessionPrimaryColor = Helper.hexToColor(json['session_primary_color']),
        sessionSecondaryColor =
            Helper.hexToColor(json['session_secondary_color']),
        sessionName = json['session_name'],
        sessionId = json['session_id'];
}

class SessionDonationRequest extends DonationRequest {
  SessionDonationRequest.fromJson(Map<String, dynamic> json)
      : super.fromJson(json);
}
