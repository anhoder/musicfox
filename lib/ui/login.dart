import 'package:colorful_cmd/component.dart';
import 'package:console/console.dart';

Future<void> login(WindowUI ui) async {
  Console.showCursor();
  Console.adapter.echoMode = true;
  Console.moveCursor(row: ui.startRow, column: ui.startColumn);
  Console.write('账号: ');
  Console.moveCursor(row: ui.startRow+2, column: ui.startColumn);
  Console.write('密码: ');
  Console.moveCursorUp(2);
  Future account = readInput('');
  Future password = readInput('', secret: true);
  await Future.wait(<Future>[account, password]).then((data) {
    Console.hideCursor();
  });
}