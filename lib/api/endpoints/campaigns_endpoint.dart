import 'package:one_d_m/api/api_call.dart';
import 'package:one_d_m/api/endpoints/api_endpoint.dart';
import 'package:one_d_m/api/stream_result.dart';
import 'package:one_d_m/models/campaign_models/base_campaign.dart';
import 'package:one_d_m/models/campaign_models/campaign.dart';

class CampaignsEndpoint extends ApiEndpoint<BaseCampaign>
    with SubscribableEndpoint, CampaignEndpointQueries {
  CampaignsEndpoint([String route = "campaigns"])
      : super(route,
            formatter: (map) => Campaign.fromJson(map),
            listFormatter: BaseCampaign.listFromJson);

  Future<Campaign> getOne([String? id]) {
    return id == null
        ? ApiCall<Campaign>(this).getOne()
        : ApiCall<Campaign>(this.addRoute(id)).getOne();
  }

  Stream<StreamResult<Campaign>> streamGetOne([String? id]) {
    return id == null
        ? ApiCall<Campaign>(this).streamGetOne()
        : ApiCall<Campaign>(this.addRoute(id)).streamGetOne();
  }

  @override
  CampaignsEndpoint addRoute(String routeToAdd) {
    String finalRoute = route + '/' + routeToAdd;
    return CampaignsEndpoint(finalRoute);
  }
}

class QueriedCampaignEndpoint = QueryableEndpoint<BaseCampaign>
    with CampaignEndpointQueries;

mixin CampaignEndpointQueries on ApiEndpoint<BaseCampaign> {
  QueriedCampaignEndpoint organizationId(String oid) {
    return QueriedCampaignEndpoint(route,
        query: {...(query ?? {}), 'organization_id': oid},
        formatter: formatter,
        listFormatter: listFormatter);
  }

  QueriedCampaignEndpoint category(int categoryId) {
    return QueriedCampaignEndpoint(route,
        query: {...(query ?? {}), 'category_id': categoryId},
        formatter: formatter,
        listFormatter: listFormatter);
  }

  QueriedCampaignEndpoint limit(int limit) {
    return QueriedCampaignEndpoint(route,
        query: {...(query ?? {}), 'limit': limit},
        formatter: formatter,
        listFormatter: listFormatter);
  }

  QueriedCampaignEndpoint name(String q) {
    return QueriedCampaignEndpoint(route,
        query: {...(query ?? {}), 'name': q},
        formatter: formatter,
        listFormatter: listFormatter);
  }
}
