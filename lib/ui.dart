import 'dart:async';
import 'dart:io';

import 'package:colorful_cmd/utils.dart';
import 'package:console/console.dart';
import 'package:console/curses.dart';
import 'package:musicfox/languages.dart';
import 'package:musicfox/menu_item.dart';

class MusicFoxUI extends Window {
  bool showWelcome;
  bool showTitle;
  String welcomeMsg;
  Color primaryColor;
  int welcomeDuration;
  Map<String, String> lang;
  List<String> list;

  bool _hasShownWelcome = false;
  int _selectIndex = 0;
  int _startRow;
  int _startColumn;
  bool _doubleColumn;
  String _menuTitle = '网易云音乐';
  final List<MenuItem> _menuStack = [];

  MusicFoxUI(
      {this.showTitle = true,
      this.showWelcome = true,
      this.welcomeMsg = 'musicfox',
      dynamic primaryColor = 'random',
      this.welcomeDuration = 2000,
      this.list,
      this.lang = ZH})
      : super(' musicfox ') {
    if ((!(primaryColor is String) || primaryColor != 'random') &&
        !(primaryColor is Color)) {
      primaryColor = 'random';
    }
    if (primaryColor is String && primaryColor == 'random') {
      this.primaryColor = randomColor();
    } else if (primaryColor is Color) {
      this.primaryColor = primaryColor;
    }
    if (list == null) {
      list ??= ['help'];
    } else {
      list.add('help');
    }
    list = _toLocal(list, lang);
  }

  @override
  void draw() {
    Console.eraseDisplay(2);
    Console.moveCursor(row: 1, column: 1);

    if (showWelcome) {
      if (_hasShownWelcome && showTitle) {
        _displayTitle();
      }
    } else if (showTitle) {
      _displayTitle();
    }

    if (showWelcome && !_hasShownWelcome) {
      _displayWelcome(welcomeMsg);
      Timer.periodic(Duration(milliseconds: 100), (timer) {
        if (timer.tick >= (welcomeDuration / 100).round()) {
          _hasShownWelcome = true;
          timer.cancel();
          draw();
        } else {
          var column = ((Console.columns - 26) / 2).floor();
          Console.write('\r');
          Console.moveToColumn(column);
          Console.setTextColor(Color.GRAY.id,
              bright: Color.GRAY.bright, xterm: Color.GRAY.xterm);
          Console.write(
              'Enter after ${(welcomeDuration / 1000 - timer.tick * 0.1).toStringAsFixed(1)} seconds...');
        }
      });
    } else {
      _displayList();
    }
  }

  @override
  void initialize() {
    Console.hideCursor();
    Keyboard.bindKeys(['q', 'Q']).listen(_quit);
    Keyboard.bindKeys([KeyCode.UP, 'k', 'K']).listen(_moveUp);
    Keyboard.bindKeys([KeyCode.DOWN, 'j', 'J']).listen(_moveDown);
    Keyboard.bindKeys([KeyCode.LEFT, 'h', 'H']).listen(_moveLeft);
    Keyboard.bindKeys([KeyCode.RIGHT, 'l', 'L']).listen(_moveRight);
  }

  void enterMenu([List<String> sonList]) {
    if (_selectIndex > list.length) return;
    sonList ??= [];
    _menuStack.add(MenuItem(list, _selectIndex, _menuTitle));

    _earseMenuTitle();
    _menuTitle = list[_selectIndex];
    _selectIndex = 0;
    list = sonList;
    _displayList();
  }

  void backMenu() {
    if (_menuStack.isEmpty) return;
    var menu = _menuStack.removeLast();

    _earseMenuTitle();
    list = menu.list;
    _selectIndex = menu.index;
    _menuTitle = menu.menuTitle;
    _displayList();
  }

  void _earseMenuTitle() {
    var lines = _doubleColumn ? (list.length / 2).ceil() : list.length;
    _repeatFunction((i) {
      Console.moveCursor(row: _startRow + i - 1);
      Console.eraseLine();
    }, lines);
  }

  void _displayWelcome(String welcomeMsg) {
    var msg = formatChars(welcomeMsg);
    var lines = msg.split('\n');
    var width = lines.length > 1 ? lines[1].length : 0;
    var height = lines.length;
    var column = ((Console.columns - width) / 2).floor();
    var row = ((Console.rows - height) / 3).floor();

    Console.setTextColor(primaryColor.id,
        bright: primaryColor.bright, xterm: primaryColor.xterm);
    lines.forEach((line) {
      Console.moveCursor(column: column, row: row);
      Console.write(line);
      row++;
    });
    Console.moveCursor(column: column, row: row);
  }

  void _displayTitle() {
    var width = Console.columns;
    var height = Console.rows;

    Console.resetAll();
    _repeatFunction((i) {
      Console.setTextColor(Color.GRAY.id, bright: Color.GRAY.bright, xterm: Color.GRAY.xterm);
      if (i == 1 || i == width) {
        Console.write('+');
        Console.moveCursorDown(height);
        Console.moveCursorBack();
        Console.write('+');
        Console.moveCursorUp(height);
      } else {
        Console.write('=');
        Console.moveCursorDown(height);
        Console.moveCursorBack();
        Console.write('=');
        Console.moveCursorUp(height);
      }
    }, width);

    Console.resetAll();
    Console.setTextColor(primaryColor.id,
        bright: primaryColor.bright, xterm: primaryColor.xterm);
    Console.moveCursor(
      row: 1,
      column: (Console.columns / 2).round() - (title.length / 2).round(),
    );
    Console.write(title);
    _repeatFunction((i) => Console.write('\n'), Console.rows - 1);
    Console.moveCursor(row: 2, column: 1);
    Console.centerCursor(row: true);
    Console.resetBackgroundColor();
  }

  void _displayList() {
    var width = Console.columns;
    var height = Console.rows;
    _doubleColumn = width >= 60;
    _startRow = (height / 3).floor();
    _startColumn = _doubleColumn ? ((width - 60) / 2).floor() : ((width - 20) / 2).floor();

    Console.resetAll();
    Console.moveCursor(row: _startRow - 3, column: _doubleColumn ? _startColumn + 15 : _startColumn + 6);
    Console.setTextColor(Color.GREEN.id, bright: Color.GREEN.bright, xterm: Color.GREEN.xterm);
    Console.eraseLine();
    Console.write(_menuTitle);

    Console.resetAll();
    Console.setTextColor(Color.WHITE.id, bright: false, xterm: false);
    var lines = _doubleColumn ? (list.length / 2).ceil() : list.length;
    for (var i = 0; i < lines; i++) {
      _displayLine(i);
    }
  }

  void _displayLine(int line) {
    Console.write('\r');
    var index = _doubleColumn ? line * 2 : line;
    Console.moveCursor(row: _startRow + line, column: _doubleColumn ? _startColumn + 15 : _startColumn + 6);
    _displayItem(index);
    if (_doubleColumn && index < list.length - 1) {
      Console.moveCursor(row: _startRow + line, column: _startColumn + 40);
      _displayItem(index + 1);
    }
  }

  void _displayItem(int index) {
    Console.moveCursorBack(4);
    if (_selectIndex == index) {
      Console.setTextColor(primaryColor.id, bright: primaryColor.bright, xterm: primaryColor.xterm);
      Console.write(' => ${index}. ${list[index]}');
      Console.resetAll();
    } else {
      Console.write('    ${index}. ${list[index]}');
    }
  }

  void _quit(_) {
    Console.showCursor();
    close();
    Console.resetAll();
    Console.eraseDisplay();
    exit(0);
  }

  void _moveDown(_) {
    int curLine;
    if (_doubleColumn) {
      if (_selectIndex + 2 > list.length - 1) {
        return;
      }
      _selectIndex += 2;
      curLine = (_selectIndex / 2).floor();
    } else {
      if (_selectIndex + 1 > list.length - 1) {
        return;
      }
      _selectIndex++;
      curLine = _selectIndex;
    }
    _displayLine(curLine - 1);
    _displayLine(curLine);
  }

  void _moveUp(_) {
    int curLine;
    if (_doubleColumn) {
      if (_selectIndex - 2 < 0) {
        return;
      }
      _selectIndex -= 2;
      curLine = (_selectIndex / 2).floor();
    } else {
      if (_selectIndex - 1 < 0) {
        return;
      }
      _selectIndex--;
      curLine = _selectIndex;
    }
    _displayLine(curLine + 1);
    _displayLine(curLine);
  }

  void _moveLeft(_) {
    if (!_doubleColumn || _selectIndex % 2 == 0 || _selectIndex - 1 < 0) {
      return;
    }
    _selectIndex -= 1;
    var curLine = (_selectIndex / 2).floor();
    _displayLine(curLine);
  }

  void _moveRight(_) {
    if (!_doubleColumn || _selectIndex % 2 != 0 || _selectIndex + 1 > list.length - 1) {
      return;
    }
    _selectIndex += 1;
    var curLine = (_selectIndex / 2).floor();
    _displayLine(curLine);
  }

}

void _repeatFunction(Function func, int times) {
  for (var i = 1; i <= times; i++) {
    func(i);
  }
}

List<String> _toLocal(List<String> list, Map<String, String> lang) {
  var res = list.map((item) {
    if (lang.containsKey(item)) {
      return lang[item];
    } else {
      return item;
    }
  });

  return res.toList();
}