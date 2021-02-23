import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/Campaign.dart';

import 'AdBalance.dart';

class DonationDialogManager extends ChangeNotifier {
  bool _showThankYou = false,
      _loading = false,
      _customAmount = false,
      _anonym = false,
      _useDCs = true,
      _hasPaymentMethod = false,
      _showAnimation = false;
  AdBalance _adBalance;
  int _amount, defaultSelectedAmount;
  Campaign _alternativCampaign;
  final Campaign campaign;

  final Stream<AdBalance> adBalanceStream;
  final String sessionId;

  DonationDialogManager(
      {this.adBalanceStream,
      this.defaultSelectedAmount,
      this.sessionId,
      this.campaign}) {
    _adBalance = AdBalance(dcBalance: 0, activityScore: 0);
    _amount = defaultSelectedAmount;
    _hasPaymentMethod = true;
    adBalanceStream.listen(_adBalanceListener);
    // hasPaymentMethodStream.listen(_hasPaymentMethodListener);
  }

  AdBalance get adBalance => _adBalance;

  set adBalance(AdBalance ab) {
    _adBalance = ab;
    notifyListeners();
  }

  bool get hasPaymentMethod => _hasPaymentMethod;

  set hasPaymentMethod(bool hpm) {
    _hasPaymentMethod = hpm;
    notifyListeners();
  }

  bool get useDCs => _useDCs;

  set useDCs(bool use) {
    _useDCs = use;
    notifyListeners();
  }

  void setUseDCsWithoutRebuild(bool use) {
    _useDCs = use;
  }

  int get amount => _amount;

  set amount(int a) {
    _amount = a;
    notifyListeners();
  }
  void setAmountWithoutRebuild(int amount) {
   _amount = amount;
  }


  bool get customAmount => _customAmount;

  set customAmount(bool ca) {
    _customAmount = ca;
    notifyListeners();
  }

  Campaign get alternativCampaign => _alternativCampaign;

  set alternativCampaign(Campaign c) {
    _alternativCampaign = c;
    notifyListeners();
  }

  void setAlternativCampaignWithoutRebuild(Campaign c) {
    _alternativCampaign = c;
  }

  bool get anonym => _anonym;

  set anonym(bool a) {
    _anonym = a;
    notifyListeners();
  }

  void setAnonymWithoutRebuild(bool a) {
    _anonym = a;
  }

  bool get showThankYou => _showThankYou;

  set showThankYou(bool sty) {
    _showThankYou = sty;
    notifyListeners();
  }

  bool get showAnimation => _showAnimation;

  set showAnimation(bool sty) {
    _showAnimation = sty;
    notifyListeners();
  }

  bool get loading => _loading;

  set loading(bool l) {
    _loading = l;
    notifyListeners();
  }

  void setLoadingWithoutRebuild(bool l) {
    _loading = l;
  }

  void _adBalanceListener(AdBalance ab) {
    if (ab != null) adBalance = ab;
  }

  void _hasPaymentMethodListener(bool hpm) {
    hasPaymentMethod = hpm;
  }
}
