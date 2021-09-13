import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:one_d_m/api/stream_result.dart';

import 'api.dart';
import 'endpoints/api_endpoint.dart';

class ApiCall<T> {
  final ApiEndpoint endpoint;
  final bool useCache, autoFormat, useCacheFirst;
  Exception exception;
  Future<String> userToken;

  ApiCall(this.endpoint,
      {this.useCache = true,
      this.autoFormat = true,
      this.useCacheFirst = false}) {
    this.exception = ApiException(endpoint: endpoint.route);
    userToken = updateUserToken();
  }

  String _buildQuery() {
    if (endpoint.query.isEmpty) return "";
    return "?" +
        endpoint.query.entries
            .map((e) => e.key + "=" + e.value.toString())
            .join("&");
  }

  Future _requestAndDecode() async {
    Box box = Api.box;

    if (box == null) await Api().init();

    String query = _buildQuery();
    String url = endpoint.baseUrl + query;
    String boxKey = endpoint.route + query;

    bool usedCache = false;
    http.Response res;
    bool containsKey = box?.containsKey(boxKey) ?? false;

    if (useCacheFirst && containsKey) return box.get(boxKey);

    if (useCache && containsKey) {
      try {
        res = await http
            .get(url, headers: Api.authHeaders)
            .timeout(Duration(milliseconds: 2000), onTimeout: () {
          usedCache = true;
          return http.Response('used cache', 200);
        });
      } catch (e) {
        print("Error occured while getting $boxKey");
        print("Returned Cache Data instead!");
        res = http.Response('used cache', 200);
      }
    } else {
      res = await http.get(url, headers: Api.authHeaders);
    }

    if (usedCache) print("USED CACHE TO FETCH $boxKey");

    if (res.statusCode == 200 && res.body == 'used cache') {
      return box.get(boxKey);
    }

    if (res.statusCode == 200) {
      final jsonData = jsonDecode(res.body);
      if (useCache && !usedCache) await box?.put(boxKey, jsonData);
      return jsonData;
    }

    if (containsKey) return box.get(boxKey);

    throwExceptionFromBody(res.body);
  }

  Stream<StreamResult> _requestAndDecodeStream() async* {
    Box box = Api.box;
    String query = _buildQuery();
    String url = endpoint.baseUrl + query;
    String boxKey = endpoint.route + query;

    http.Response res;

    // await Future.delayed(Duration(seconds: 2));
    bool containsKey = box?.containsKey(boxKey) ?? false;

    if (containsKey) yield StreamResult(fromCache: true, data: box.get(boxKey));

    await userToken;

    res = await http.get(url, headers: Api.authHeaders);

    if (res.statusCode == 200) {
      final jsonData = jsonDecode(res.body);
      await box.put(boxKey, jsonData);
      yield StreamResult(fromCache: false, data: jsonData);
    } else {
      throwExceptionFromBody(res.body);
    }
  }

  Stream<StreamResult<List<T>>> streamGet() {
    Stream<StreamResult> res = _requestAndDecodeStream();

    res = res.map<StreamResult<List<T>>>((val) {
      List<Map<String, dynamic>> lMap = List<Map<String, dynamic>>.from(
          val.data.map((v) => Map<String, dynamic>.from(v)));
      return StreamResult<List<T>>(
          fromCache: val.fromCache, data: endpoint.listFormatter(lMap));
    });

    return res;
  }

  Stream<StreamResult<T>> streamGetOne() {
    Stream<StreamResult> res = _requestAndDecodeStream().asBroadcastStream();

    res = res.map<StreamResult<T>>((v) => StreamResult<T>(
        fromCache: v.fromCache,
        data: autoFormat
            ? endpoint.formatter(Map<String, dynamic>.from(v.data))
            : Map<String, dynamic>.from(v.data)));

    return res;
  }

  Future<List<T>> get([Map<String, dynamic> query]) async {
    await userToken;

    List res = await _requestAndDecode();

    res = res.map((v) => Map<String, dynamic>.from(v)).toList();

    return endpoint.listFormatter(List<Map<String, dynamic>>.from(res));
  }

  Future<String> updateUserToken() async {
    String token = await auth.FirebaseAuth.instance.currentUser?.getIdToken();
    Api.updateUserToken(token);
    return token;
  }

  Future<T> getOne() async {
    await userToken;
    Map res = await _requestAndDecode();

    Map<String, dynamic> castedMap = Map<String, dynamic>.from(res);

    return autoFormat ? endpoint.formatter(castedMap) : castedMap;
  }

  Future<T> post(Map<String, dynamic> body) async {
    await userToken;
    http.Response res = await http.post(endpoint.baseUrl,
        headers: {...Api.authHeaders, ...Api.bodyHeaders},
        body: jsonEncode(body));

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return autoFormat
          ? endpoint.formatter(Map<String, dynamic>.from(body))
          : body;
    }

    throwExceptionFromBody(res.body);
  }

  Future<void> put([Map<String, dynamic> body]) async {
    await userToken;
    http.Response res = await http.put(endpoint.baseUrl,
        headers: {...Api.authHeaders, ...Api.bodyHeaders},
        body: body != null ? jsonEncode(body) : null);

    if (res.statusCode == 200) return;

    throwExceptionFromBody(res.body);
  }

  Future<void> delete() async {
    await userToken;
    http.Response res =
        await http.delete(endpoint.baseUrl, headers: Api.authHeaders);

    if (res.statusCode == 200) return;

    throwExceptionFromBody(res.body);
  }

  void throwExceptionFromBody(String body) {
    throw (body?.isNotEmpty ?? false) ? Exception(body) : exception;
  }
}
