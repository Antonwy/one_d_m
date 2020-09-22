export interface DonationType {
  alternative_campaign_id?: string;
  amount: number;
  campaign_id: string;
  campaign_img_url: string;
  campaign_name: string;
  created_at: FirebaseFirestore.Timestamp;
  user_id: string;
  anonym: boolean;
}

export interface UserType {
  admin: boolean;
  donated_amount: number;
  name: string | null;
  image_url: string | null;
  subscribed_campaigns: string[];
}

export interface PrivateUserDataType {
  email_address: string;
  phone_number: string;
  customer_id: string;
  device_token: string;
}

export interface CampaignType {
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
