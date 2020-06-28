import 'package:colorful_cmd/component.dart';
import 'package:musicfox/cache/i_cache.dart';
import 'package:musicfox/exception/response_exception.dart';
import 'package:musicfox/ui/login.dart';

/// 检查是否登录，未登录调起登录
Future<void> checkLogin(WindowUI ui) async {
  var cache = CacheFactory.produce();
  var user = cache.get('user');
  if (user == null) await login(ui);
}

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