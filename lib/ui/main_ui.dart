import 'dart:async';
import 'dart:io';

import 'package:colorful_cmd/component.dart';
import 'package:colorful_cmd/utils.dart';
import 'package:console/console.dart';
import 'package:mp3_player/audio_player.dart';
import 'package:musicfox/cache/i_cache.dart';
import 'package:musicfox/exception/response_exception.dart';
import 'package:musicfox/lang/chinese.dart';
import 'package:musicfox/ui/menu_content/daily_recommend_songs.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';
import 'package:musicfox/utils/music_info.dart';
import 'package:musicfox/utils/music_progress.dart';
import 'package:musicfox/utils/player_status.dart';
import 'package:netease_music_request/request.dart' as request;

final MENU_CONTENTS = <IMenuContent>[
  DailyRecommendSongs(),

];

class MainUI {
  WindowUI _window;
  Player _playerContainer;
  int _curSongIndex;

  // from player
  MusicInfo _curMusicInfo; 
  MusicProgress _curProgress;
  PlayerStatus _playerStatus;
  

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
      init: init,
      lang: Chinese()
    );
    CacheFactory.produce();
    _curMusicInfo = MusicInfo();
    _curProgress = MusicProgress();
    _playerStatus = PlayerStatus();
  }

  Future<Player> get _player async {
    if (_playerContainer == null) {
      _playerContainer = await Player.run();
      _playerContainer.listenMusicInfo((musicInfo) {
        _curMusicInfo.setValue(musicInfo['title'], musicInfo['artist'], musicInfo['album'], musicInfo['year'], musicInfo['comment'], musicInfo['genre'], musicInfo['track']);
      });
      _playerContainer.listenProgress((progress) => _curProgress.setValue(progress['cur'], progress['left']));
      _playerContainer.listenStatus((status) async {
        _playerStatus.setStatus(status);
        if (_playerStatus.status == Status.STOPPED) {
          Timer(Duration(milliseconds: 500), () async {
            if (_playerStatus.status == Status.STOPPED) {
              List songs = _window.pageData;
              if (songs == null || _curSongIndex >= songs.length - 1) return;
              _curSongIndex++;
              Map songInfo = songs[_curSongIndex];
              if (!songInfo.containsKey('id')) return;
              await playSong(songInfo['id']);
            }
          });
        }
      });
    }
    return _playerContainer;
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

  /// 初始化
  void init(WindowUI ui) {
    Keyboard.bindKey(KeyName.SPACE).listen(play);
  }

  /// 进入菜单
  Future<List<String>> beforeEnterMenu(WindowUI ui) async {
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
    return [];
  }

  /// 翻页
  Future<List<String>> beforeNextPage(WindowUI ui) async {
    await Future.delayed(Duration(seconds: 1));
    return Future.value([]);
  }

  /// 播放音乐
  void play(_) async {
    List songs = _window.pageData;
    var index = _window.selectIndex;
    if (songs == null || index > songs.length - 1) return;
    _curSongIndex = index;
    Map songInfo = songs[_curSongIndex];
    if (!songInfo.containsKey('id')) return;

    var player = (await _player);
    if (_curMusicInfo.id == songInfo['id']) {
      if (_playerStatus.status == Status.PAUSED || _playerStatus.status == Status.STOPPED) {
        player.resume();
      } else {
        player.pause();
      }
    } else {
      await playSong(songInfo['id']);
    }

  }

  Future<void> playSong(int songId) async {
    var songRequest = request.Song();
    Map songUrl = await songRequest.getSongUrlByWeb(songId);
    songUrl = songUrl['data'][0];
    if (!songUrl.containsKey('url')) return;
    (await _player).playWithoutList(songUrl['url']);
    _curMusicInfo.setId(songId);
  }

}