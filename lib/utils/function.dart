import 'package:musicfox/exception/response_exception.dart';

/// 验证响应
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

/// 格式化秒
String formatTime(int milliseconds) {
  var m = (milliseconds / 60000).floor();
  var s = ((milliseconds / 1000) % 60).floor();
  return '${m >= 10 ? m : '0${m}'}:${s >= 10 ? s : '0${s}'}';
}