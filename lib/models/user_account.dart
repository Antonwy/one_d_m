import 'package:one_d_m/helper/helper.dart';
import 'package:one_d_m/models/campaign_models/base_campaign.dart';
import 'package:one_d_m/models/session_models/base_session.dart';
import 'package:one_d_m/models/user.dart';

class UserAccount extends User {
  // anzahl personen die dem nutzer folgen
  final int followedCount;
  // anzahl personen der der nutzer folgt
  final int followingCount;
  final List<User> followingUsers;
  final List<BaseSession> subscribedSessions;
  final List<BaseCampaign> subscribedCampaigns;

  UserAccount.fromJson(Map<String, dynamic> map)
      : followedCount = map['followed_count'] ?? 0,
        followingCount = map['following_count'] ?? 0,
        followingUsers =
            User.listFromJson(Helper.castJson(map['following_users'] ?? [])),
        subscribedSessions = BaseSession.listFromJson(
            Helper.castJson(map['subscribed_sessions'] ?? [])),
        subscribedCampaigns = BaseCampaign.listFromJson(
            Helper.castJson(map['subscribed_campaigns'] ?? [])),
        super.fromJson(map);
}
