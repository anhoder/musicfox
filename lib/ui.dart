import 'dart:async';
import 'dart:io';

import 'package:colorful_cmd/utils.dart';
import 'package:console/console.dart';
import 'package:console/curses.dart';

class MusicFoxUI extends Window {
  bool showWelcome;
  bool showTitle;
  String welcomeMsg;
  Color primaryColor;
  int welcomeDuration;

  bool _hasShownWelcome = false;

  MusicFoxUI(
      {this.showTitle = true,
      this.showWelcome = true,
      this.welcomeMsg = 'musicfox',
      dynamic primaryColor = 'random',
      this.welcomeDuration = 2000})
      : super('musicfox') {
    if ((!(primaryColor is String) || primaryColor != 'random') &&
        !(primaryColor is Color)) {
      primaryColor = 'random';
    }
    if (primaryColor is String && primaryColor == 'random') {
      this.primaryColor = randomColor();
    } else if (primaryColor is Color) {
      this.primaryColor = primaryColor;
    }
  }

  @override
  void draw() {
    Console.eraseDisplay(2);
    Console.moveCursor(row: 1, column: 1);

    if (showWelcome) {
      if (_hasShownWelcome && showTitle) {
        displayTitle();
      }
    } else if (showTitle) {
      displayTitle();
    }

    if (showWelcome && !_hasShownWelcome) {
      displayWelcome(welcomeMsg);
      Timer.periodic(Duration(milliseconds: 100), (timer) {
        if (timer.tick >= (welcomeDuration / 100).round()) {
          _hasShownWelcome = true;
          timer.cancel();
          draw();
        } else {
          var column = ((Console.columns - 26) / 2).floor();
          Console.write('\r');
          Console.moveToColumn(column);
          Console.setTextColor(Color.GRAY.id, bright: Color.GRAY.bright, xterm: Color.GRAY.xterm);
          Console.write('Enter after ${(welcomeDuration / 1000 - timer.tick * 0.1).toStringAsFixed(1)} seconds...');
        }
      });
    }
  }

  @override
  void initialize() {
    Keyboard.bindKeys(['q', 'Q']).listen((_) {
      close();
      Console.resetAll();
      Console.eraseDisplay();
      exit(0);
    });
  }

  void displayWelcome(String welcomeMsg) {
    var msg = formatChars(welcomeMsg);
    var lines = msg.split('\n');
    var width = lines.length > 1 ? lines[1].length : 0;
    var height = lines.length;
    var column = ((Console.columns - width) / 2).floor();
    var row = ((Console.rows - height) / 3).floor();

    Console.setTextColor(primaryColor.id, bright: primaryColor.bright, xterm: primaryColor.xterm);
    lines.forEach((line) {
      Console.moveCursor(column: column, row: row);
      Console.write(line);
      row++;
    });
    Console.moveCursor(column: column, row: row);
  }

  void displayTitle() {
    _repeatFunction((i) => Console.write(' '), Console.columns);
    Console.setTextColor(primaryColor.id, bright: primaryColor.bright, xterm: primaryColor.xterm);
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

  void moveCenterColumn() {
    var row = (Console.rows / 2).round();
    Console.moveCursor(row: row, column: 0);
  }
}

void _repeatFunction(Function func, int times) {
  for (var i = 1; i <= times; i++) {
    func(i);
  }
}
