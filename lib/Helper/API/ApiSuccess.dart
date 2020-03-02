
import 'ApiResult.dart';

class ApiSuccess<E> extends ApiResult<E> {

  ApiSuccess({E data, String message}) : super(data: data, message: message);

  @override
  bool hasError() => false;

}