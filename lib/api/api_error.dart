import 'api_result.dart';

class ApiError<E> extends ApiResult<E> {
  ApiError(String? message) : super(data: null, message: message);

  @override
  E getData() => throw new ArgumentError("API Error occured");

  @override
  bool hasError() => true;
}
