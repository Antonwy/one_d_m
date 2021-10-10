import 'package:one_d_m/helper/helper.dart';

class SearchResult {
  final List<SearchResultItem>? campaigns;
  final List<SearchResultItem>? users;
  final List<SearchResultItem>? organizations;
  final List<SearchResultItem>? sessions;

  SearchResult({this.campaigns, this.users, this.organizations, this.sessions});

  SearchResult.fromJson(Map<String, dynamic> map)
      : campaigns = SearchResultItem.listFromJson(
            Helper.castList<Map<String, dynamic>>(map['campaigns']),
            SearchResultType.campaigns),
        sessions = SearchResultItem.listFromJson(
            Helper.castList<Map<String, dynamic>>(map['sessions']),
            SearchResultType.sessions),
        organizations = SearchResultItem.listFromJson(
            Helper.castList<Map<String, dynamic>>(map['organizations']),
            SearchResultType.organizations),
        users = SearchResultItem.listFromJson(
            Helper.castList<Map<String, dynamic>>(map['users']),
            SearchResultType.users);

  @override
  String toString() {
    return 'SearchResult(campaigns: $campaigns, users: $users, organizations: $organizations, sessions: $sessions)';
  }
}

class SearchResultItem {
  final String? blurHash, imageUrl, thumbnailUrl, name, id;
  final SearchResultType type;

  SearchResultItem.fromJson(Map<String, dynamic> map, this.type)
      : blurHash = map['blur_hash'],
        imageUrl = map['image_url'],
        name = map.containsKey('name') ? map['name'] : map['title'],
        thumbnailUrl = map['thumbnail_url'],
        id = map['id'];

  static List<SearchResultItem> listFromJson(
      List<Map<String, dynamic>> list, SearchResultType type) {
    return list.map((m) => SearchResultItem.fromJson(m, type)).toList();
  }

  @override
  String toString() {
    return "name: " + name!;
  }
}

enum SearchResultType { campaigns, organizations, users, sessions }
