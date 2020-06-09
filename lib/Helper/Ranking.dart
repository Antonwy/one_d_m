import 'package:cloud_firestore/cloud_firestore.dart';

abstract class Ranking {
  static final DAILYRANKINGS = "daily_rankings",
      CAMPAIGNS = "campaigns",
      USERS = "users",
      AMOUNT = "amount";

  final List<DonatedAmount> topRank;

  Ranking(this.topRank);

  static String getFormatedDate([DateTime date]) {
    DateTime dt = date ?? DateTime.now();
    return "${dt.year}-${dt.month}-${dt.day}";
  }
}

class FriendsRanking extends Ranking {
  FriendsRanking(List<DonatedAmount> topRank) : super(topRank);

  static FriendsRanking fromQuery(QuerySnapshot qs) {
    List<DonatedAmount> list = [];
    qs.documents.forEach((doc) {
      list.add(DonatedAmount.fromDocument(doc));
    });
    return FriendsRanking(list);
  }
}

class CampaignsRanking extends Ranking {
  CampaignsRanking(List<DonatedAmount> topRank) : super(topRank);

  static CampaignsRanking fromQuery(QuerySnapshot qs) {
    List<DonatedAmount> list = [];
    qs.documents.forEach((doc) {
      list.add(DonatedAmount.fromDocument(doc));
    });
    return CampaignsRanking(list);
  }
}

class DonatedAmount {
  final int amount;
  final String id;

  DonatedAmount(this.amount, this.id);

  static DonatedAmount fromDocument(DocumentSnapshot doc) {
    return DonatedAmount(doc[Ranking.AMOUNT], doc.documentID);
  }

  bool operator ==(element) {
    return element is DonatedAmount && element.id == id;
  }

  @override
  String toString() {
    return "$amount, $id";
  }
}
