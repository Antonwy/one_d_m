export interface Donation {
  alternative_campaign_id?: string;
  amount: number;
  campaign_id: string;
  campaign_img_url: string;
  campaign_name: string;
  created_at: any;
  user_id: string;
}

export interface User {
  admin: boolean;
  donated_amount: number;
  first_name: string | null;
  last_name: string | null;
  image_url: string | null;
  subscribed_campaigns: string[];
}

export interface PrivateUserData {
  email_address: string;
  phone_number: string;
  customer_id: string;
}

export interface Campaign {
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

export interface News {
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
