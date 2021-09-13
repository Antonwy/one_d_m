import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:hive/hive.dart';
import 'package:one_d_m/api/api_call.dart';
import 'package:one_d_m/api/endpoints/account_endpoint.dart';
import 'package:one_d_m/api/endpoints/campaigns_endpoint.dart';
import 'package:one_d_m/api/endpoints/donation_request_endpoint.dart';
import 'package:one_d_m/api/endpoints/donations_endpoint.dart';
import 'package:one_d_m/api/endpoints/news_endpoint.dart';
import 'package:one_d_m/api/endpoints/organizations_endpoint.dart';
import 'package:one_d_m/api/endpoints/search_endpoint.dart';
import 'package:one_d_m/api/endpoints/sessions_endpoint.dart';
import 'package:one_d_m/api/endpoints/statistics_endpoint.dart';
import 'package:one_d_m/api/endpoints/users_endpoint.dart';
import 'package:one_d_m/api/stream_result.dart';
import 'package:one_d_m/models/search_result.dart';
import 'package:one_d_m/models/user.dart';

class Api {
  static final Api _api = Api._internal();
  static String userToken;
  static Box box;
  static final String url =
      "http://localhost:3000" ?? "https://one-dollar-movement.appspot.com";

  factory Api() => _api;

  Future<void> init() async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    userToken = await currentUser?.getIdToken();
    if (currentUser != null) box = await Hive.openBox(boxName(currentUser.uid));
    authHeaders = {'authtoken': userToken};
  }

  Future<void> reInit() async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;

    if (currentUser != null && userToken == null)
      userToken = await currentUser.getIdToken();
    if (currentUser != null &&
        !(await Hive.boxExists(boxName(currentUser.uid))))
      box = await Hive.openBox(boxName(currentUser.uid));

    authHeaders = userToken != null ? {'authtoken': userToken} : {};
  }

  Future<void> disconnect() async {
    userToken = null;
    authHeaders = {};
    await box.clear();
  }

  String boxName(String uid) => 'api_cache_$uid';

  AccountEndpoint account() => AccountEndpoint();
  UsersEndpoint users() => UsersEndpoint();
  CampaignsEndpoint campaigns() => CampaignsEndpoint();
  SessionsEndpoint sessions() => SessionsEndpoint();
  OrganizationsEndpoint organizations() => OrganizationsEndpoint();
  DonationsEndpoint donations() => DonationsEndpoint();
  NewsEndpoint news() => NewsEndpoint();
  DonationRequestEndpoint donationRequest() => DonationRequestEndpoint();
  StatisticsEndpoint statistics() => StatisticsEndpoint();

  static void updateUserToken(String token) {
    userToken = token;
    authHeaders = userToken != null ? {'authtoken': userToken} : {};
  }

  static Map<String, String> authHeaders = {'authtoken': userToken};
  static Map<String, String> bodyHeaders = {
    'Content-Type': 'application/json; charset=UTF-8'
  };

  Future<User> getAccount() {
    return account().getOne();
  }

  Future<SearchResult> search(String query) {
    return ApiCall<SearchResult>(SearchEndpoint("search?query=$query"))
        .getOne();
  }

  Stream<StreamResult<SearchResult>> searchStream(String query) {
    return ApiCall<SearchResult>(SearchEndpoint("search?query=$query"))
        .streamGetOne();
  }

  Api._internal();
}
