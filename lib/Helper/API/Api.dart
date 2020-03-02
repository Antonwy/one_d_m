import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:one_d_m/Helper/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Campaign.dart';
import '../Constants.dart';
import 'ApiResult.dart';

class Api {

  static Future<ApiResult> register(User user) async {
    http.Response res =
        await http.post("${Constants.BASE_URL}/register", body: user.toMap());

    ApiResult result = ApiResult.fromJson(res.body);

    if(!result.hasError()) await _saveCredentials(username: user.username, password: user.password);

    return result;
  }

  static Future<ApiResult> login({String username, String password}) async {

    http.Response res = await http.get("${Constants.BASE_URL}/user",
        headers: <String, String>{
          'authorization': _basicAuth(password: password, username: username)
        });

    ApiResult result = ApiResult.fromJson(res.body);

    if(!result.hasError()) await _saveCredentials(username: username, password: password);

    return result;
  }

  static Future<ApiResult<User>> getUser() async {
    print('Getting User...');
    http.Response res = await http.get("${Constants.BASE_URL}/user",
        headers: {'authorization': await _basicAuthStorage()});

    return ApiResult.fromJson(res.body, User.fromJson);
  }

  static Future<User> getUserWithId(int id) async {
    http.Response res = await http.get("${Constants.BASE_URL}/user/$id",
        headers: {'authorization': await _basicAuthStorage()});

    Map<String, dynamic> jsonRes = json.decode(res.body);

    if (jsonRes["successful"]) {
      return User.fromJson(jsonRes["data"]);
    } else {
      print('Something went wrong getting the userdata');
    }
  }

  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> createCampaign(Campaign campaign) async {
    print(campaign);
    http.Response res = await http.post("${Constants.BASE_URL}/project",
        headers: <String, String>{'authorization': await _basicAuthStorage()},
        body: campaign.toMap());

    print(res.body);

    return json.decode(res.body)["successful"];
  }

  static String _basicAuth({String username, String password}) {
    return 'Basic ' + base64Encode(utf8.encode('$username:$password'));
  }

  static Future<String> _basicAuthStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String username = prefs.getString(Constants.USERNAME);
    String password = prefs.getString(Constants.PASSWORD);

    return _basicAuth(username: username, password: password);
  }

  static Future<void> _saveCredentials(
      {String username, String password}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.USERNAME, username);
    await prefs.setString(Constants.PASSWORD, password);
  }

  static Future<ApiResult<List<Campaign>>> getCampaigns() async {
    print("Getting Campaigns...");
    http.Response res = await http.get('${Constants.BASE_URL}/projects',
        headers: <String, String>{'authorization': await _basicAuthStorage()});

    return ApiResult<List<Campaign>>.fromJson(res.body, Api.parseCampaigns);
  }

  static Future<ApiResult> getSubscribedCampaigns() async {

    ApiResult<User> userRes = await Api.getUser();

    http.Response res = await http.get(
        '${Constants.BASE_URL}/user/${userRes.getData().id}/subscriptions',
        headers: <String, String>{'authorization': await _basicAuthStorage()});

    return ApiResult.fromJson(res.body, Api.parseCampaigns);
  }

  static Future<bool> subscribe(int projId) async {
    http.Response res = await http.post(
        '${Constants.BASE_URL}/project/$projId/subscription',
        headers: <String, String>{'authorization': await _basicAuthStorage()});

    dynamic parsedJson = json.decode(res.body);

    return parsedJson["successful"];
  }

  static Future<bool> deleteSubscription(int projId) async {
    http.Response res = await http.delete(
        '${Constants.BASE_URL}/project/$projId/subscription',
        headers: <String, String>{'authorization': await _basicAuthStorage()});
    
    dynamic parsedJson = json.decode(res.body);

    return parsedJson["successful"];
  }

  static List<Campaign> parseCampaigns(Map<String, dynamic> map) {
    List<dynamic> data = map["data"];
    List<Campaign> campaigns = [];
    for (dynamic c in data) {
      campaigns.add(Campaign.fromJson(c));
    }
    return campaigns;
  }

}
