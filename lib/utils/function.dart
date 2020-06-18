import 'package:musicfox/exception/response_exception.dart';

Map validateResponse(Map response) {
  if (response['code'] == 400) {
    throw ResponseException('输入错误');
  } else {
    if (response['code'] >= 500) {
      throw ResponseException(response['msg'] ?? '');
    }
  }
  return response;
}