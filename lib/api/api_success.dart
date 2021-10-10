import 'api_result.dart';

class ApiSuccess<E> extends ApiResult<E> {
  ApiSuccess({E? data, String message = "Successfull fetched"})
      : super(data: data, message: message);

  @override
  bool hasError() => false;
}
