import 'package:colorful_cmd/component.dart';
import 'package:colorful_cmd/utils.dart';
import 'package:console/console.dart';
import 'package:netease_music_request/request.dart';

Future<Map> search(WindowUI ui, int type, String menu) async {
  ui.menuTitle = '按${menu}搜索';
  ui.displayMenuTitle();
  
  ui.earseMenu();

  Console.showCursor();
  Console.adapter.lineMode = true;
  Console.adapter.echoMode = true;
  Console.moveCursor(row: ui.startRow, column: ui.startColumn);
  Console.write(ColorText().gray('${menu}: ').toString());
  var keywords = await readInput('', checker: (response) {
    Console.hideCursor();
    Console.adapter.echoMode = false;
    Console.adapter.lineMode = false;
    return true;
  });

  var search = Search();
  var response = await search.search(keywords, type: type);

  ui.earseMenu();

  return response;
}