import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/api/stream_result.dart';
import 'package:one_d_m/models/campaign_models/base_campaign.dart';
import 'package:one_d_m/models/campaign_models/campaign.dart';
import 'package:provider/provider.dart';

class CampaignManager extends ChangeNotifier {
  BaseCampaign? baseCampaign;
  Campaign? campaign;
  Stream<StreamResult<Campaign>>? campaignStream;
  bool? loadingCampaign = true, subscribed = false, fromCache = true;
  int subscribedCount = 0;

  final TabController? tabController;
  int? tabIndex = 0;

  CampaignManager(this.baseCampaign, {this.tabController}) {
    this.campaignStream = baseCampaign is Campaign
        ? Stream.value(
            StreamResult(fromCache: false, data: baseCampaign as Campaign))
        : Api().campaigns().streamGetOne(baseCampaign!.id);
    initData();
    tabController?.addListener(() {
      tabIndex = tabController!.index;
      notifyListeners();
    });
  }

  CampaignManager.copy(
      {this.baseCampaign,
      this.tabController,
      this.campaign,
      this.campaignStream,
      this.loadingCampaign,
      this.subscribed,
      this.fromCache,
      required this.subscribedCount,
      this.tabIndex});

  CampaignManager copyCM() => CampaignManager.copy(
      baseCampaign: baseCampaign,
      tabController: tabController,
      campaign: campaign,
      campaignStream: campaignStream,
      loadingCampaign: loadingCampaign,
      fromCache: fromCache,
      subscribed: subscribed,
      subscribedCount: subscribedCount,
      tabIndex: tabIndex);

  Future<void> initData() async {
    await for (StreamResult<Campaign> result in campaignStream!) {
      campaign = result.data;
      baseCampaign = campaign;
      subscribed = campaign!.subscribed;
      subscribedCount = campaign!.memberCount;
      loadingCampaign = false;
      fromCache = result.fromCache;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    campaign = await Api().campaigns().getOne(baseCampaign!.id);
    baseCampaign = campaign;
    subscribed = campaign!.subscribed;
    loadingCampaign = false;
    notifyListeners();
  }

  Future<void> leaveOrJoinCampaign(bool join, BuildContext context) async {
    try {
      if (join)
        await Api().campaigns().subscribe(baseCampaign!.id);
      else
        await Api().campaigns().unsubscribe(baseCampaign!.id);

      await context.read<FirebaseAnalytics>().logEvent(
          name: "${join ? 'Joined' : 'Left'} Campaign",
          parameters: {"campaign": baseCampaign!.id});
    } catch (e) {
      print("something went wrong subscribing!");
      return;
    }
    subscribed = join;
    subscribedCount += join ? 1 : -1;
    notifyListeners();
  }
}
