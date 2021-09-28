import 'dart:async';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/api/api_call.dart';
import 'package:one_d_m/api/stream_result.dart';

abstract class ApiEndpoint<T> {
  final String route;
  final T Function(Map<String, dynamic>)? formatter;
  final List<T> Function(List<Map<String, dynamic>>)? listFormatter;
  final Map<String, dynamic>? query;
  final Uri baseUrl;
  bool apiUseCache;

  ApiEndpoint(this.route,
      {this.formatter,
      this.listFormatter,
      this.apiUseCache = true,
      this.query = const {}})
      : this.baseUrl = Uri.parse('${Api.url}/$route');

  ApiEndpoint<T> addRoute(String routeToAdd);

  Future<T> getOne([String? id]) async {
    if (id != null) return ApiCall<T>(this.addRoute(id)).getOne();
    return ApiCall<T>(this).getOne();
  }

  Future<List<T>> get() async {
    return ApiCall<T>(this).get();
  }

  Stream<StreamResult<List<T>>> streamGet() {
    return ApiCall<T>(this).streamGet();
  }

  Stream<StreamResult<T>> streamGetOne([String? id]) {
    if (id != null) return ApiCall<T>(this.addRoute(id)).streamGetOne();
    return ApiCall<T>(this).streamGetOne();
  }
}

mixin SubscribableEndpoint<T> on ApiEndpoint<T> {
  Future<void> subscribe(String sid) async {
    return ApiCall(this.addRoute(sid).addRoute('subscribe')).put();
  }

  Future<void> unsubscribe(String sid) async {
    return ApiCall(this.addRoute(sid).addRoute("unsubscribe")).put();
  }
}

class QueryableEndpoint<T> extends ApiEndpoint<T> {
  QueryableEndpoint(String route,
      {Map<String, dynamic>? query,
      T Function(Map<String, dynamic> map)? formatter,
      List<T> Function(List<Map<String, dynamic>>)? listFormatter})
      : super(route,
            query: query, formatter: formatter, listFormatter: listFormatter);

  @override
  QueryableEndpoint<T> addRoute(String routeToAdd) {
    String finalRoute = route + '/' + routeToAdd;
    return QueryableEndpoint(finalRoute);
  }
}

class ApiException implements Exception {
  final String endpoint;
  final String? message;

  ApiException({this.endpoint = "/", this.message});

  @override
  String toString() {
    return message ?? "Fehler bei der Abfrage von $endpoint";
  }
}
