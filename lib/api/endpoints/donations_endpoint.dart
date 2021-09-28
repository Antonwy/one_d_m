import 'package:one_d_m/api/api_call.dart';
import 'package:one_d_m/api/endpoints/api_endpoint.dart';
import 'package:one_d_m/models/donation.dart';

class DonationsEndpoint extends ApiEndpoint<Donation>
    with DonationEndpointQueries {
  DonationsEndpoint([String route = "donations"])
      : super(route,
            formatter: (map) => Donation.fromJson(map),
            listFormatter: Donation.listFromJson);

  Future<Donation> create(Donation donation) {
    return ApiCall<Donation>(this).post(donation.toMap());
  }

  @override
  DonationsEndpoint addRoute(String routeToAdd) {
    String finalRoute = route + '/' + routeToAdd;
    return DonationsEndpoint(finalRoute);
  }
}

class QueriedDonationEndpoint = QueryableEndpoint<Donation>
    with DonationEndpointQueries;

mixin DonationEndpointQueries on ApiEndpoint<Donation> {
  QueriedDonationEndpoint user(String uid) {
    return QueriedDonationEndpoint(route,
        query: {...(query ?? {}), 'user_id': uid},
        formatter: formatter,
        listFormatter: listFormatter);
  }

  QueriedDonationEndpoint campaign(String cid) {
    return QueriedDonationEndpoint(route,
        query: {...(query ?? {}), 'campaign_id': cid},
        formatter: formatter,
        listFormatter: listFormatter);
  }

  QueriedDonationEndpoint session(String sid) {
    return QueriedDonationEndpoint(route,
        query: {...(query ?? {}), 'session_id': sid},
        formatter: formatter,
        listFormatter: listFormatter);
  }
}
