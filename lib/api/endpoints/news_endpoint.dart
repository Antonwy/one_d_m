import 'package:one_d_m/api/endpoints/api_endpoint.dart';
import 'package:one_d_m/models/news.dart';

class NewsEndpoint extends ApiEndpoint<News> {
  NewsEndpoint([String route = "news"])
      : super(route,
            formatter: (v) => News.fromJson(v),
            listFormatter: (l) => News.listFromJson(l));
}
