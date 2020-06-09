import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'Campaign.dart';
import 'User.dart';

class CampaignsManager with ChangeNotifier {
  List<Campaign> _campaigns = [];

  CampaignsManager() {
    Firestore.instance
        .collection("campaigns")
        .snapshots()
        .listen(onCampaignsChange);
  }

  void onCampaignsChange(QuerySnapshot qs) {
    _campaigns = Campaign.listFromSnapshot(qs.documents);
    notifyListeners();
  }

  List<Campaign> queryCampaigns(String query) {
    return _campaigns
        .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<Campaign> getCampaingsFrom(String id) {
    return _campaigns.where((Campaign c) => c.authorId == id).toList();
  }

  List<Campaign> getCampaignFromCategoryId(int catId) {
    if (catId < 0 || catId > 2) return getAllCampaigns();
    return _campaigns.where((Campaign c) => c.categoryId == catId).toList();
  }

  List<Campaign> getAllCampaigns() {
    return _campaigns;
  }

  List<Campaign> getSubscribedCampaigns(User user) {
    return _campaigns
        .where((Campaign c) => user.subscribedCampaignsIds.contains(c.id))
        .toList();
  }

  Campaign getCampaign(String id) =>
      _campaigns.firstWhere((element) => element.id == id);
}
