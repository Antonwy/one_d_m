import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:one_d_m/Helper/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Campaign.dart';
import 'Constants.dart';

class Api {
  static Future<String> register(User user) async {
    http.Response res =
        await http.post("${Constants.BASE_URL}/register", body: user.toMap());

    Map<String, dynamic> body = json.decode(res.body);

    if (body["successful"] == true) {
      print('Successfully Registered!');
      await _saveCredentials(username: user.username, password: user.password);
      return null;
    } else {
      print('Something went wrong registering the user');
      return body["errors"];
    }
  }

  static Future<String> login({String username, String password}) async {

    http.Response res = await http.get("${Constants.BASE_URL}/user",
        headers: <String, String>{
          'authorization': _basicAuth(password: password, username: username)
        });

    Map<String, dynamic> body = json.decode(res.body);

    if (body["successful"] == true) {
      print("Successful logged in!");
      await _saveCredentials(username: username, password: password);
      return null;
    } else {
      print("Something went wrong!");
      return body["errors"];
    }
  }

  static Future<User> getUser() async {
    http.Response res = await http.get("${Constants.BASE_URL}/user",
        headers: {'authorization': await _basicAuthStorage()});

    Map<String, dynamic> jsonRes = json.decode(res.body);

    if (jsonRes["successful"]) {
      return User.fromJson(jsonRes["data"]);
    } else {
      print('Something went wrong getting the userdata');
    }
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

  static Future<List<Campaign>> getCampaigns() async {
    http.Response res = await http.get('${Constants.BASE_URL}/projects',
        headers: <String, String>{'authorization': await _basicAuthStorage()});

    dynamic parsedJson = json.decode(res.body);

    if (!parsedJson["successful"]) return null;

    List<dynamic> data = parsedJson["data"];

    List<Campaign> campaigns = [];

    for (dynamic c in data) {
      campaigns.add(Campaign.fromJson(c));
    }

    return campaigns;
  }

  static Future<List<Campaign>> getSubscribedCampaigns(int userId) async {
    http.Response res = await http.get(
        '${Constants.BASE_URL}/user/$userId/subscriptions',
        headers: <String, String>{'authorization': await _basicAuthStorage()});

    dynamic parsedJson = json.decode(res.body);

    if (!parsedJson["successful"]) return null;

    List<dynamic> data = parsedJson["data"];

    List<Campaign> campaigns = [];

    for (dynamic c in data) {
      campaigns.add(Campaign.fromJson(c));
    }

    return campaigns;
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
}
