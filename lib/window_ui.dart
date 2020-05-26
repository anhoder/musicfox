import 'dart:async';
import 'dart:io';

import 'package:colorful_cmd/utils.dart';
import 'package:console/console.dart';
import 'package:console/curses.dart';
import 'package:musicfox/languages.dart';
import 'package:musicfox/menu_item.dart';

class WindowUI extends Window {
  String name;
  bool showWelcome;
  bool showTitle;
  String welcomeMsg;
  Color primaryColor;
  int welcomeDuration;
  Map<String, String> lang;
  List<String> menu;
  List<String> Function(WindowUI) beforeEnterMenu;

  String _menuTitle;
  bool _hasShownWelcome = false;
  int _selectIndex = 0;
  int _startRow;
  int _startColumn;
  bool _doubleColumn;
  final List<MenuItem> _menuStack = [];

  WindowUI(
      {this.showTitle = true,
      this.showWelcome = true,
      this.welcomeMsg = 'musicfox',
      dynamic primaryColor = 'random',
      this.welcomeDuration = 2000,
      this.name = 'MUSICFOX',
      this.menu,
      this.lang = ZH,
      defaultMenuTitle = '------',
      this.beforeEnterMenu})
      : super(' ${name} ') {
    if ((!(primaryColor is String) || primaryColor != 'random') &&
        !(primaryColor is Color)) {
      primaryColor = 'random';
    }
    if (primaryColor is String && primaryColor == 'random') {
      this.primaryColor = randomColor();
    } else if (primaryColor is Color) {
      this.primaryColor = primaryColor;
    }

    if (defaultMenuTitle != null) _menuTitle = defaultMenuTitle;

    if (menu == null) {
      menu = ['help'];
    } else {
      menu.add('help');
    }
    menu = _toLocal(menu, lang);
  }

  @override
  void draw() {
    Console.eraseDisplay(2);
    Console.moveCursor(row: 1, column: 1);

    if ((showWelcome && _hasShownWelcome && showTitle) ||
      (!showWelcome && showTitle)) _displayTitle();

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
    Keyboard.bindKey('n').listen((_) => enterMenu());
    Keyboard.bindKey('b').listen((_) => backMenu());
  }

  void enterMenu() {
    if (_selectIndex > menu.length) return;
    _menuStack.add(MenuItem(menu, _selectIndex, _menuTitle));
    _earseMenu();
    _menuTitle = menu[_selectIndex];
    _selectIndex = 0;

    menu = beforeEnterMenu == null ? [] : (beforeEnterMenu(this) ?? []);

    _displayList();
  }

  void backMenu() {
    if (_menuStack.isEmpty) return;
    var menuItem = _menuStack.removeLast();

    _earseMenu();
    menu = menuItem.list;
    _selectIndex = menuItem.index;
    _menuTitle = menuItem.menuTitle;
    _displayList();
  }

  void _earseMenu() {
    var lines = _doubleColumn ? (menu.length / 2).ceil() : menu.length;
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

  void _displayBorder() {
    var width = Console.columns;

    Console.resetAll();
    _repeatFunction((i) {
      Console.setTextColor(Color.GRAY.id, bright: Color.GRAY.bright, xterm: Color.GRAY.xterm);
      if (i < (width / 2).round()) {
        Console.write('<');
      } else {
        Console.write('>');
      }
    }, width);
  }

  void _displayTitle() {
    _displayBorder();
    Console.resetAll();
    Console.setTextColor(Color.GRAY.id, bright: Color.GRAY.bright, xterm: Color.GRAY.xterm);
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
    
    if (showTitle && _startRow > 2) {
      Console.resetAll();
      var row = _startRow > 4 ? _startRow - 3 : 2;
      Console.moveCursor(row: row, column: _doubleColumn ? _startColumn + 15 : _startColumn + 6);
      Console.setTextColor(Color.GREEN.id, bright: Color.GREEN.bright, xterm: Color.GREEN.xterm);
      Console.eraseLine();
      Console.write(_menuTitle);
    } else if (!showTitle && _startRow > 1) {
      var row = _startRow > 3 ? _startRow - 3 : 2;
      Console.moveCursor(row: row, column: _doubleColumn ? _startColumn + 15 : _startColumn + 6);
      Console.setTextColor(Color.GREEN.id, bright: Color.GREEN.bright, xterm: Color.GREEN.xterm);
      Console.eraseLine();
      Console.write(_menuTitle);
    }

    Console.resetAll();
    Console.setTextColor(Color.WHITE.id, bright: false, xterm: false);
    var lines = _doubleColumn ? (menu.length / 2).ceil() : menu.length;
    for (var i = 0; i < lines; i++) {
      _displayLine(i);
    }
  }

  void _displayLine(int line) {
    Console.write('\r');
    var index = _doubleColumn ? line * 2 : line;
    Console.moveCursor(row: _startRow + line, column: _doubleColumn ? _startColumn + 15 : _startColumn + 6);
    _displayItem(index);
    if (_doubleColumn && index < menu.length - 1) {
      Console.moveCursor(row: _startRow + line, column: _startColumn + 40);
      _displayItem(index + 1);
    }
  }

  void _displayItem(int index) {
    Console.moveCursorBack(4);
    if (_selectIndex == index) {
      Console.setTextColor(primaryColor.id, bright: primaryColor.bright, xterm: primaryColor.xterm);
      Console.write(' => ${index}. ${menu[index]}');
      Console.resetAll();
    } else {
      Console.write('    ${index}. ${menu[index]}');
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
      if (_selectIndex + 2 > menu.length - 1) {
        return;
      }
      _selectIndex += 2;
      curLine = (_selectIndex / 2).floor();
    } else {
      if (_selectIndex + 1 > menu.length - 1) {
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
    if (!_doubleColumn || _selectIndex % 2 != 0 || _selectIndex + 1 > menu.length - 1) {
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