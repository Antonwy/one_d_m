import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:one_d_m/api/stream_result.dart';
import 'package:one_d_m/provider/api_manager.dart';
import 'package:provider/provider.dart';

import 'api.dart';
import 'endpoints/api_endpoint.dart';

typedef Json = Map<String, dynamic>;

class ApiCall<T> {
  final ApiEndpoint endpoint;
  final bool useCache, autoFormat, useCacheFirst, withAuthHeader;
  Exception exception;
  Future<String>? userToken;

  ApiCall(this.endpoint,
      {this.useCache = true,
      this.autoFormat = true,
      this.useCacheFirst = false,
      this.withAuthHeader = true})
      : exception = ApiException(endpoint: endpoint.route) {
    userToken = updateUserToken();
  }

  String _buildQuery() {
    if (endpoint.query == null || (endpoint.query?.isEmpty ?? true)) return "";

    return "?" +
        endpoint.query!.entries
            .map((e) => e.key + "=" + e.value.toString())
            .join("&");
  }

  FutureOr _requestAndDecode() async {
    Box? box = Api.box;

    if (box == null) await Api().init();

    String query = _buildQuery();
    Uri url = Uri.parse(endpoint.baseUrl.toString() + query);
    String boxKey = endpoint.route + query;

    bool usedCache = false;
    http.Response res;
    bool containsKey = box?.containsKey(boxKey) ?? false;

    if (box != null && useCacheFirst && containsKey) return box.get(boxKey);

    if (useCache && containsKey) {
      try {
        res = await http
            .get(url, headers: withAuthHeader ? Api.authHeaders : {})
            .timeout(Duration(milliseconds: 2000), onTimeout: () {
          usedCache = true;
          return http.Response('used cache', 200);
        });
      } on SocketException catch (se) {
        print("Error occured while getting $boxKey! Cache data AVAILABLE");
        handleSocketException(se);
        res = http.Response('used cache', 200);
      } catch (e) {
        print("Error occured while getting $boxKey! Cache data AVAILABLE");
        print(e);
        res = http.Response('used cache', 200);
      }
    } else {
      try {
        res =
            await http.get(url, headers: withAuthHeader ? Api.authHeaders : {});
      } on SocketException catch (se) {
        handleSocketException(se);
        throw new Exception(
            "Error occured while getting $boxKey! NO cache available!");
      } catch (e) {
        print(e);
        throw new Exception(
            "Error occured while getting $boxKey! NO cache available!");
      }
    }

    if (usedCache) print("USED CACHE TO FETCH $boxKey");

    if (box != null && res.statusCode == 200 && res.body == 'used cache') {
      return box.get(boxKey);
    }

    if (res.statusCode == 200) {
      try {
        final jsonData = jsonDecode(res.body);
        if (useCache && !usedCache) await box?.put(boxKey, jsonData);
        Api.manager.setApiReachable();
        return jsonData;
      } catch (e) {
        print(e);
        print(res.body);
        throw e;
      }
    }

    if (box != null && containsKey) return box.get(boxKey);

    throwExceptionFromBody(res.body);
  }

  Stream<StreamResult> _requestAndDecodeStream() async* {
    Box? box = Api.box;

    if (box == null) await Api().init();

    String query = _buildQuery();
    Uri url = Uri.parse(endpoint.baseUrl.toString() + query);
    String boxKey = endpoint.route + query;

    http.Response res;

    // await Future.delayed(Duration(seconds: 2));
    bool containsKey = box?.containsKey(boxKey) ?? false;

    if (box != null && containsKey)
      yield StreamResult(fromCache: true, data: box.get(boxKey));

    await userToken;

    try {
      res = await http.get(url, headers: withAuthHeader ? Api.authHeaders : {});

      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        Api.manager.setApiReachable();
        if (box != null) await box.put(boxKey, jsonData);
        yield StreamResult(fromCache: false, data: jsonData);
      } else {
        throwExceptionFromBody(res.body);
      }
    } on SocketException catch (se) {
      print("ERROR GETTING STREAM HTTP $boxKey");
      handleSocketException(se);
    } catch (e) {
      print("ERROR GETTING STREAM HTTP $boxKey : $e");
    }
  }

  void handleSocketException(SocketException se) {
    print("APIMANAGER: ${Api.manager}");
    if (se.osError?.errorCode == 61) Api.manager.setApiNotReachable();
  }

  Stream<StreamResult<List<T?>>> streamGet() {
    Stream<StreamResult> res = _requestAndDecodeStream();

    res = res.map<StreamResult<List<T?>>>((val) {
      List<Json> lMap = List<Json>.from(val.data.map((v) => Json.from(v)));

      if (endpoint.listFormatter != null)
        return StreamResult<List<T?>>(
            fromCache: val.fromCache,
            data: endpoint.listFormatter!(lMap) as List<T?>?);
      else
        throw new Exception("Specify a list formatter!");
    });

    return res as Stream<StreamResult<List<T?>>>;
  }

  Stream<StreamResult<T>> streamGetOne() {
    Stream<StreamResult> res = _requestAndDecodeStream().asBroadcastStream();

    res = res.map<StreamResult<T>>((v) => StreamResult<T>(
        fromCache: v.fromCache,
        data: autoFormat
            ? endpoint.formatter!(Json.from(v.data))
            : Json.from(v.data) as T?));

    return res as Stream<StreamResult<T>>;
  }

  Future<List<T?>> get([Json? query]) async {
    await userToken;

    List res = await _requestAndDecode();

    res = res.map((v) => Json.from(v)).toList();

    return endpoint.listFormatter!(List<Json>.from(res)) as FutureOr<List<T?>>;
  }

  Future<String> updateUserToken() async {
    String? token =
        (await auth.FirebaseAuth.instance.currentUser?.getIdToken());
    if (token != null) Api.updateUserToken(token);

    return "";
  }

  Future<T> getOne() async {
    await userToken;
    Map res = await _requestAndDecode();

    Json castedMap = Json.from(res);

    return autoFormat
        ? endpoint.formatter!(castedMap)
        : castedMap as FutureOr<T?>;
  }

  Future<T?> post(dynamic body) async {
    await userToken;
    http.Response res = await http.post(endpoint.baseUrl,
        headers: {...Api.authHeaders, ...Api.bodyHeaders},
        body: jsonEncode(body));

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return autoFormat ? endpoint.formatter!(Json.from(body)) : body;
    }

    throwExceptionFromBody(res.body);
  }

  Future<void> put([Json? body]) async {
    await userToken;
    http.Response res = await http.put(endpoint.baseUrl,
        headers: {
          ...Api.authHeaders as Map<String, String>,
          ...Api.bodyHeaders
        },
        body: body != null ? jsonEncode(body) : null);

    if (res.statusCode == 200) return;

    throwExceptionFromBody(res.body);
  }

  Future<void> delete() async {
    await userToken;
    http.Response res = await http.delete(endpoint.baseUrl,
        headers: Api.authHeaders as Map<String, String>?);

    if (res.statusCode == 200) return;

    throwExceptionFromBody(res.body);
  }

  void throwExceptionFromBody(String body) {
    throw (body.isNotEmpty) ? Exception(body) : exception;
  }
}
