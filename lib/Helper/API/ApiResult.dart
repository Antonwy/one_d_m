import 'dart:convert';

import 'package:one_d_m/Helper/API/ApiError.dart';
import 'package:one_d_m/Helper/API/ApiSuccess.dart';

class ApiResult<E> {

  String message;
  E data;

  ApiResult({this.message, this.data});

  factory ApiResult.fromJson(String data, [E Function(Map<String, dynamic>) toObj]) {
    Map<String, dynamic> map = json.decode(data);
    if(map["successful"] == true)
      return ApiSuccess(data: toObj == null ? null : toObj(map), message: "Successful fetched!");
    return ApiError(map["errors"]);
  }

  bool hasError() => false;
  String getMessage() => message;
  E getData() => data;

  String toString() => "Data: $data, Message: $message, hasError: ${hasError()}";
}