import 'dart:convert';

import 'api_error.dart';
import 'api_success.dart';

class ApiResult<E> {
  String message;
  E data;

  ApiResult({this.message, this.data});

  factory ApiResult.fromJson(String data,
      [E Function(Map<String, dynamic>) toObj]) {
    Map<String, dynamic> map = json.decode(data);
    if (map["successful"] == true)
      return ApiSuccess(
        data: toObj == null ? null : toObj(map),
      );
    return ApiError(map["errors"]);
  }

  bool hasError() => false;
  String getMessage() => message;
  E getData() => data;

  String toString() =>
      "Data: $data, Message: $message, hasError: ${hasError()}";
}
