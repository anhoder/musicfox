import 'package:colorful_cmd/component.dart';
import 'package:colorful_cmd/utils.dart';
import 'package:console/console.dart';
import 'package:musicfox/cache/i_cache.dart';
import 'package:musicfox/exception/response_exception.dart';
import 'package:musicfox/utils/function.dart';
import 'package:netease_music_request/request.dart';

Future<void> login(WindowUI ui) async {
  ui.menuTitle = '用户登录（邮箱或手机号）';
  ui.displayMenuTitle();
  
  ui.earseMenu();

  Console.showCursor();
  Console.adapter.echoMode = true;
  Console.adapter.lineMode = true;
  Console.moveCursor(row: ui.startRow, column: ui.startColumn);
  Console.write(ColorText().normal().text('账号: ').toString());
  Console.moveCursor(row: ui.startRow+2, column: ui.startColumn);
  Console.write(ColorText().normal().text('密码: ').toString());
  Console.moveCursorUp(2);
  Future accountInput = readInput('', checker: (response) {
    Console.moveCursor(row: ui.startRow+2, column: ui.startColumn);
    Console.write('密码: ');
    return true;
  });
  Future passwordInput = readInput('', secret: true, checker: (response) {
    Console.hideCursor();
  Console.adapter.echoMode = false;
  Console.adapter.lineMode = false;
    return true;
  });
  var data = await Future.wait(<Future>[accountInput, passwordInput]);
  String account = data[0];
  String password = data[1];

  var user = User();

  var response;
  if (account.indexOf('@') > 0) {
    response = await user.loginByEmail(account, password);
  } else {
    response = await user.loginByPhone(account, password);
  }

  response = validateResponse(response);

  if (response['code'] != 200) {
    throw ResponseException('账号或密码错误');
  }

  var cache = CacheFactory.produce();

  await cache.set('user', {
    'userId': response['profile']['userId'],
    'nickname': response['profile']['nickname'],
    'token': response['token']
  });

  ui.earseMenu();
}