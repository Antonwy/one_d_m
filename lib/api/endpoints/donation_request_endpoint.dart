import 'package:one_d_m/api/endpoints/api_endpoint.dart';
import 'package:one_d_m/models/donation_request.dart';

class DonationRequestEndpoint extends ApiEndpoint<DonationRequest>
    with DonationRequestEndpointQueries {
  DonationRequestEndpoint([String route = "donationRequest"])
      : super(route, formatter: (map) => DonationRequest.fromJson(map));
}

class QueriedDonationRequestEndpoint = QueryableEndpoint<DonationRequest>
    with DonationRequestEndpointQueries;

mixin DonationRequestEndpointQueries on ApiEndpoint<DonationRequest> {
  QueriedDonationRequestEndpoint campaign(String cid) {
    return QueriedDonationRequestEndpoint(route,
        query: {...query, 'campaign_id': cid},
        formatter: formatter,
        listFormatter: listFormatter);
  }

  QueriedDonationRequestEndpoint session(String sid) {
    return QueriedDonationRequestEndpoint(route,
        query: {...query, 'session_id': sid},
        formatter: formatter,
        listFormatter: listFormatter);
  }
}
