export interface DonationType {
  alternative_campaign_id?: string;
  amount: number;
  campaign_id: string;
  campaign_img_url: string;
  campaign_name: string;
  created_at: FirebaseFirestore.Timestamp;
  user_id: string;
  anonym: boolean;
  useDCs?: boolean;
  session_id?: string | null;
}

export interface UserType {
  id?: string;
  admin: boolean;
  donated_amount: number;
  name: string | null;
  image_url: string | null;
  thumbnail_url: string | null;
  subscribed_campaigns: string[];
}

export interface PrivateUserDataType {
  email_address: string;
  phone_number: string;
  customer_id: string;
  device_token: string;
}

export interface CampaignType {
  id?: string;
  authorId: string;
  city: string;
  created_at: any;
  current_amount: number;
  description: string;
  image_url: string;
  short_description: string;
  subscribed_count: number;
  target_amount: number;
  title: string;
  dv_controller?: number;
  donation_unit?: string;
}

export interface NewsType {
  campaign_id: string;
  campaign_img_url: string;
  campaign_name: string;
  created_at: any;
  image_url: string;
  short_text: string;
  text: string;
  title: string;
  user_id: string;
}

export interface StatisticType {
  yearly_amount?: number;
  monthly_amount?: number;
  daily_amount?: number;
}

export interface ChargesType {
  campaign_id?: string;
  user_id?: string;
  amount: FirebaseFirestore.FieldValue;
  error?: boolean;
  charged?: boolean;
}

export interface UploadedSessionType {
  campaign: CampaignType;
  members: Array<UserType>;
  session_name: string;
  session_description: string;
  amount_per_user: number;
}

export interface SessionType {
  campaign_name: string;
  campaign_id: string;
  campaign_img_url: string;
  campaign_short_description: string;
  session_name: string;
  session_description: string;
  amount_per_user: number;
  current_amount: number;
  created_at: FirebaseFirestore.Timestamp;
  end_date: FirebaseFirestore.Timestamp;
  creator_id: string;
  img_url?: string;
  donation_goal_current?: number;
  donation_goal?: number;
}

export interface UserSessionType {
  id: string;
  session_name: string;
  session_description: string;
  amount_per_user: number;
  created_at: FirebaseFirestore.Timestamp;
  end_date: FirebaseFirestore.Timestamp;
  creator_id: string;
  campaign_id: string;
  img_url?: string;
}

export interface SessionMemberType {
  id: string;
  donation_amount: number;
  created_at: FirebaseFirestore.Timestamp;
}

export interface SessionInviteType {
  id: string;
  session_name: string;
  session_creator: string;
  session_description: string;
  amount_per_user: number;
}
