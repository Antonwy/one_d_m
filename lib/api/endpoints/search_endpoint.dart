import 'package:one_d_m/api/endpoints/api_endpoint.dart';
import 'package:one_d_m/models/search_result.dart';

class SearchEndpoint extends ApiEndpoint<SearchResult> {
  SearchEndpoint([String route = "search"])
      : super(route, formatter: (v) => SearchResult.fromJson(v));

  @override
  SearchEndpoint addRoute(String? routeToAdd) {
    String finalRoute = route + '/' + routeToAdd!;
    return SearchEndpoint(finalRoute);
  }
}
