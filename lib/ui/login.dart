import 'package:colorful_cmd/component.dart';
import 'package:console/console.dart';

Future<void> login(WindowUI ui) async {
  Console.showCursor();
  Console.adapter.echoMode = true;
  Console.moveCursor(row: ui.startRow, column: ui.startColumn);
  Console.write('账号: ');
  var account = await readInput('');
  Console.moveCursor(row: ui.startRow+2, column: ui.startColumn);
  Console.write('密码: ');
  var password = await readInput('', secret: true);
  Console.hideCursor();
  print(account);
  print(password);
}