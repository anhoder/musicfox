import 'dart:io';

import 'package:colorful_cmd/component.dart';
import 'package:colorful_cmd/utils.dart';
import 'package:console/console.dart';
import 'package:musicfox/exception/response_exception.dart';
import 'package:musicfox/lang/chinese.dart';
import 'package:musicfox/ui/menu_content/daily_recommend_songs.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';

final MENU_CONTENTS = <IMenuContent>[
  DailyRecommendSongs(),

];

class MainUI {
  WindowUI _window;

  MainUI() {
    _window = WindowUI(
      name: 'MusicFox', 
      welcomeMsg: 'MUSICFOX', 
      menu: <String>[
        '每日推荐歌曲',
        '每日推荐歌单',
        '我的歌单',
        '私人FM',
        '新歌上架',
        '搜索',
        '排行榜',
        '精选歌单',
        '热门歌手',
        '主播电台',
        '云盘',
      ],
      defaultMenuTitle: '网易云音乐',
      beforeEnterMenu: beforeEnterMenu,
      beforeNextPage: beforeNextPage,
      lang: Chinese()
    );
  }

  /// 显示UI
  void display() {
    _window.display();
  }

  /// 清除菜单
  void earseMenu() {
    _window.earseMenu();
  }

  /// 输出错误
  void error(String text) {
    writeLine(ColorText().red(text).normal().toString());
  }

  /// 写信息
  void writeLine(String text) {
    earseMenu();
    Console.moveCursor(row: _window.startRow, column: _window.startColumn);
    Console.write(text);
  }

  /// 进入菜单
  Future<List<String>> beforeEnterMenu(ui) async {
    try {
      var menuContents = MENU_CONTENTS;
      Iterable stack = ui.menuStack.length > 1 ? ui.menuStack.getRange(0, ui.menuStack.length - 2) : [];
      await stack.forEach((menuItem) async {
        var menu = menuContents[menuItem.index];
        if (menu is IMenuContent) {
          menuContents = await menu.getMenuContent(ui);
        }
      });
      var menus = await menuContents[ui.selectIndex].getMenus(ui);
      if (menus != null && menus.isNotEmpty) return menus;
      var content = await menuContents[ui.selectIndex].getContent(ui);
      var row = ui.startRow;
      content.split('\n').forEach((line) {
        Console.moveCursor(row: row, column: ui.startColumn);
        Console.write(line);
        row++;
      });
    } on SocketException {
      error('网络错误~, 请稍后重试');
    } on ResponseException catch (e) {
      error(e.toString());
    }
  }

  /// 翻页
  Future<List<String>> beforeNextPage(ui) async {
    await Future.delayed(Duration(seconds: 1));
    return Future.value([]);
  }
}