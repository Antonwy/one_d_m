export class DatabaseConstants {
  static readonly campaigns: string = 'campaigns';
  static readonly campaigns_info: string = 'campaigns_info';
  static readonly campaigns_subscribed_users: string =
    'campaigns_subscribed_users';
  static readonly subscribed_campaigns: string = 'subscribed_campaigns';
  static readonly donation_feed: string = 'donation_feed';
  static readonly donations: string = 'donations';
  static readonly donation_info: string = 'donation_info';
  static readonly followed: string = 'followed';
  static readonly following: string = 'following';
  static readonly friends: string = 'friends';
  static readonly news: string = 'news';
  static readonly news_feed: string = 'news_feed';
  static readonly statistics: string = 'statistics';
  static readonly daily_rankings: string = 'daily_rankings';
  static readonly users_info: string = 'users_info';
  static readonly user: string = 'user';
  static readonly users: string = 'users';
  static readonly private_data: string = 'private_data';
  static readonly advertising_data: string = 'ad_data';
  static readonly data: string = 'data';
  static readonly ad_impressions: string = 'impressions';
  static readonly ad_balance: string = 'balance';
  static readonly cards: string = 'cards';
  static readonly organisations: string = 'organizations';
  static readonly session_id: string = 'session_id';
  static readonly charges_users: string = 'charges_users';
  static readonly charges_campaigns: string = 'charges_campaigns';
  static readonly cpm_rates: string = 'cpm_rates';
  static readonly sessions: string = 'sessions';
  static readonly session_members: string = 'session_members';
  static readonly session_invites: string = 'session_invites';
  static readonly sessions_info: string = 'sessions_info';
  static readonly session_count: string = 'session_count';
  static readonly id: string = 'id';
  static readonly goals: string = 'goals';
  static readonly insgesamt: string = 'Insgesamt';
  static readonly feed: string = 'feed';
  static readonly feed_data: string = 'feed_data';
  static readonly surveys: string = 'surveys';
  static readonly results: string = 'results';
  static readonly evaluation: string = 'evaluation';
  static readonly result_count: string = 'result_count';
}

export class SurveyTypes {
  static readonly multiple_choice: string = 'multiple-choice';
  static readonly single_answer: string = 'single-answer';
}

export class CampaignFields {
  static readonly campaign_id: string = 'campaign_id';
  static readonly author_id: string = 'authorId';
}

export class DonationFields {
  static readonly user_id: string = 'user_id';
  static readonly created_at: string = 'created_at';
  static readonly campaign_id: string = 'campaign_id';
  static readonly campaign_deleted: string = 'campaign_deleted';
  static readonly session_id: string = 'session_id';
}

export class PrivateUserFields {
  static readonly phone_number: string = 'phone_number';
}

export class UserAdFields {
  static readonly native_ad_impressions: string = 'native_ad_impressions';
  static readonly interstitial_impressions: string = 'interstitial_impressions';
  static readonly activity_score: string = 'activity_score';
  static readonly dc_balance: string = 'dc_balance';
}

export class ImageResolutions {
  static readonly low: string = '300x300';
  static readonly high: string = '1080x1920';
}

export class StorageConstants {
  static readonly storageUrlStart: string =
    'https://firebasestorage.googleapis.com/v0/b/one-dollar-movement.appspot.com/o/';
  static readonly storageUrlEnd: string = '?alt=media&token=';
}

export class ImagePrefix {
  static readonly campaign: string = 'campaign';
  static readonly news: string = 'news';
  static readonly user: string = 'user';
  static readonly certified_sessions: string = 'certified_sessions';
  static readonly session: string = 'session';
}

export class ImageSuffix {
  static readonly dottJpg: string = '.jpg';
}

export class ChargesFields {
  static readonly amount: string = 'amount';
  static readonly user_id: string = 'user_id';
}

export class SessionFields {
  static readonly campaign_name: string = 'campaign_name';
  static readonly campaign_id: string = 'campaign_id';
  static readonly campaign_img_url: string = 'campaign_img_url';
  static readonly campaign_short_description: string =
    'campaign_short_description';
  static readonly session_name: string = 'session_name';
  static readonly session_description: string = 'session_description';
  static readonly amount_per_user: string = 'amount_per_user';
  static readonly current_amount: string = 'current_amount';
  static readonly created_at: string = 'created_at';
  static readonly end_date: string = 'end_date';
  static readonly creator_id: string = 'creator_id';
}
