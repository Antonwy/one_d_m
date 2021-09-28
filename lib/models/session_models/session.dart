import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:one_d_m/components/sessions/session_donation.dart';
import 'package:one_d_m/helper/helper.dart';
import 'package:one_d_m/models/campaign_models/base_campaign.dart';
import 'package:one_d_m/models/campaign_models/campaign.dart';
import 'package:one_d_m/models/session_models/base_session.dart';
import 'package:one_d_m/models/session_models/session_member.dart';

class Session extends BaseSession {
  final List<SessionMember> members;
  final List<String> donationEffects;
  final List<SessionDonation> donations;
  final String animationUrl,
      campaignTitle,
      campaignShortDescription,
      campaignImageUrl,
      campaignThumbnailUrl,
      videoUrl;
  final bool subscribed;
  final int memberCount;

  Session.fromDoc(DocumentSnapshot doc)
      : members = [],
        memberCount = 0,
        subscribed = false,
        donationEffects = [],
        animationUrl = "",
        campaignImageUrl = "",
        campaignTitle = "",
        campaignShortDescription = "",
        campaignThumbnailUrl = "",
        donations = [],
        videoUrl = null,
        super.fromJson(doc.data());

  Session.fromJson(Map<String, dynamic> map)
      : members = SessionMember.listFromJson(Helper.castJson(map[MEMBERS])),
        donationEffects =
            Helper.castList<String>(map[BaseCampaign.DONATION_EFFECTS]),
        animationUrl = map[BaseCampaign.DV_ANIMATION],
        campaignImageUrl = map[BaseSession.CAMPAIGN_IMG_URL],
        campaignTitle = map[BaseSession.CAMPAIGN_NAME],
        campaignShortDescription = map[BaseSession.CAMPAIGN_SHORT_DESCRIPTION],
        campaignThumbnailUrl = map[BaseSession.CAMPAIGN_THUMBNAIL_URL],
        subscribed = map[SUBSCRIBED] ?? false,
        memberCount = map[MEMBER_COUNT],
        donations =
            SessionDonation.listFromJson(Helper.castJson(map[DONATIONS])),
        videoUrl = map['video_url'],
        super.fromJson(map);

  static const String MEMBERS = "members",
      MEMBER_COUNT = "member_count",
      DONATIONS = "last_donations",
      SUBSCRIBED = "subscribed";
}
