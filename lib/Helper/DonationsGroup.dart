import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

import 'Donation.dart';

class DonationsGroup {
  final String userId;
  final Map<String, DonationCampaignInfo> campaignsMap;

  DonationsGroup({
    this.userId,
    this.campaignsMap,
  });

  DonationsGroup add(Donation donation) {
    campaignsMap.update(
      donation.campaignId,
      (dci) => dci.add(donation),
      ifAbsent: () => DonationCampaignInfo.of(donation),
    );
    return this;
  }

  List<DonationCampaignInfo> get campaigns {
    List<DonationCampaignInfo> dciList = campaignsMap.values.toList();
    dciList.sort((dci1, dci2) => dci2.amount.compareTo(dci1.amount));
    return dciList;
  }

  static DonationsGroup of(Donation donation) => DonationsGroup(
      userId: donation.userId,
      campaignsMap: {donation.campaignId: DonationCampaignInfo.of(donation)});

  static List<DonationsGroup> fromQuerySnapshot(QuerySnapshot qs) {
    Map<String, DonationsGroup> groups = {};

    qs.documents.forEach((doc) {
      Donation donation = Donation.fromSnapshot(doc);

      groups.update(donation.userId, (value) => value.add(donation),
          ifAbsent: () => DonationsGroup.of(donation));
    });

    return groups.values.toList();
  }

  @override
  String toString() =>
      'DonationsGroup(userId: $userId, campaigns: $campaignsMap)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return o is DonationsGroup &&
        o.userId == userId &&
        mapEquals(o.campaignsMap, campaignsMap);
  }

  @override
  int get hashCode => userId.hashCode ^ campaignsMap.hashCode;
}

class DonationCampaignInfo {
  final String campaignId, campaignName, campaignImg;
  int amount;
  final DateTime createdAt;

  DonationCampaignInfo(
      {this.campaignId,
      this.campaignImg,
      this.campaignName,
      this.amount,
      this.createdAt});

  DonationCampaignInfo add(Donation donation) {
    amount += donation.amount;
    return this;
  }

  factory DonationCampaignInfo.of(Donation donation) => DonationCampaignInfo(
      campaignId: donation.campaignId,
      amount: donation.amount,
      campaignImg: donation.campaignImgUrl,
      campaignName: donation.campaignName,
      createdAt: donation.createdAt);

  @override
  String toString() =>
      'DonationCampaignInfo(campaignId: $campaignId, amount: $amount)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is DonationCampaignInfo &&
        o.campaignId == campaignId &&
        o.amount == amount;
  }

  @override
  int get hashCode => campaignId.hashCode ^ amount.hashCode;
}
