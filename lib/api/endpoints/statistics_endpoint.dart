import 'package:one_d_m/api/endpoints/api_endpoint.dart';
import 'package:one_d_m/models/statistics.dart';

class StatisticsEndpoint extends ApiEndpoint<Statistics> {
  StatisticsEndpoint([String route = "statistics"])
      : super(route, formatter: (map) => Statistics.fromJson(map));

  Future<Statistics> home() {
    return this.addRoute('home').getOne();
  }
}
