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
  static readonly organisations: string = 'organisations';
  static readonly charges_users: string = 'charges_users';
  static readonly charges_campaigns: string = 'charges_campaigns';
  static readonly cpm_rates: string = 'cpm_rates';
}

export class CampaignFields {
  static readonly campaign_id: string = 'campaign_id';
}

export class DonationFields {
  static readonly user_id: string = 'user_id';
  static readonly created_at: string = 'created_at';
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
}

export class ImageSuffix {
  static readonly dottJpg: string = '.jpg';
}

export class ChargesFields {
  static readonly amount: string = 'amount';
  static readonly user_id: string = 'user_id';
}
