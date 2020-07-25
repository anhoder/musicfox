import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:colorful_cmd/component.dart';
import 'package:colorful_cmd/utils.dart';
import 'package:console/console.dart';
import 'package:mp3_player/audio_player.dart';
import 'package:musicfox/cache/i_cache.dart';
import 'package:musicfox/exception/response_exception.dart';
import 'package:musicfox/lang/chinese.dart';
import 'package:musicfox/ui/login.dart';
import 'package:musicfox/ui/menu_content/albums.dart';
import 'package:musicfox/ui/bottom_out_content.dart';
import 'package:musicfox/ui/menu_content/cloud.dart';
import 'package:musicfox/ui/menu_content/daily_recommand_playlist.dart';
import 'package:musicfox/ui/menu_content/daily_recommend_songs.dart';
import 'package:musicfox/ui/menu_content/help.dart';
import 'package:musicfox/ui/menu_content/high_quality_playlist.dart';
import 'package:musicfox/ui/menu_content/hot_artist.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';
import 'package:musicfox/ui/menu_content/main_menu.dart';
import 'package:musicfox/ui/menu_content/personal_fm.dart';
import 'package:musicfox/ui/menu_content/playlist_songs.dart';
import 'package:musicfox/ui/menu_content/ranks.dart';
import 'package:musicfox/ui/menu_content/search_type.dart';
import 'package:musicfox/ui/menu_content/user_playlists.dart';
import 'package:musicfox/utils/function.dart';
import 'package:musicfox/utils/music_info.dart';
import 'package:musicfox/utils/music_progress.dart';
import 'package:musicfox/utils/play_mode.dart';
import 'package:musicfox/utils/player_status.dart';
import 'package:musicfox/version.dart';
import 'package:netease_music_request/request.dart' as request;

final MENU_CONTENTS = <IMenuContent>[
  DailyRecommendSongs(),
  DailyRecommandPlaylist(),
  UserPlaylists(),
  PersonalFm(),
  Albums(),
  SearchType(),
  Ranks(),
  HighQualityPlaylist(),
  HotArtist(),
  Cloud(),
  Help(),
];

class MainUI {
  WindowUI _window;
  Player _playerContainer;
  String _playingMenuId;
  Timer _playerTimer;
  RainbowProgress _playerProgress;
  Stopwatch _watch;
  int _curSongIndex = 0;
  List _playlist = [];
  NotifierProxy _notifier;
  final List<IMenuContent> _menuContentStack = [];
  IMenuContent _curMenuContent = MainMenu();
  PlaylistMode _playMode = PlaylistMode.ORDER;
  bool _isIntelligence = false;

  // 歌词
  Map<int, String> _curSongLyric;
  List<int> _sortedLyricTime;
  int _curLyricIndex;
  List<String> _curShowingLyrics;
  bool _firstRenderLyric;

  // from player
  MusicInfo _curMusicInfo; 
  MusicProgress _curProgress;
  PlayerStatus _playerStatus;
  

  MainUI() {
    _window = WindowUI(
      name: 'MusicFox',
      welcomeMsg: 'MUSICFOX',
      showHelp: false,
      menu: <String>[
        '每日推荐歌曲',
        '每日推荐歌单',
        '我的歌单',
        '私人FM',
        '专辑列表',
        '搜索',
        '排行榜',
        '精选歌单',
        '热门歌手',
        '云盘',
        // '主播电台',
        '帮助',
      ],
      defaultMenuTitle: '网易云音乐',
      enterMain: enterMain,
      beforeEnterMenu: beforeEnterMenu,
      beforeNextPage: beforeNextPage,
      beforeBackMenu: beforeBackMenu,
      init: init,
      quit: quit,
      lang: Chinese()
    );
    _curMusicInfo = MusicInfo();
    _curProgress = MusicProgress();
    _playerStatus = PlayerStatus();
    _watch = Stopwatch();
    _notifier = NotifierProxy(mac: [TerminalNotifier(), AppleScriptNotifier()], linux: [NotifySendNotifier()], win: [NotifuNotifier()]);
    var cache = CacheFactory.produce();
    _playMode = NAME_TO_PLAY_MODE[cache.get('playMode') ?? '顺序'];
    Map progress = cache.get('progress');
    if (progress == null) return;
    _curSongIndex = progress.containsKey('curSongIndex') ? progress['curSongIndex'] : 0;
    _playlist = progress.containsKey('playlist') ? progress['playlist'] : [];
    _playingMenuId = progress.containsKey('playingMenuId') ? progress['playingMenuId'] : null;
    signin(_notifier);
    getLatestTag().then((tag) {
      if (tag != CUR_TAG && tag != '') {
        _notifier.send(
          '点击查看更新~', 
          title: 'MusicFox', 
          subtitle: '最新版本${tag}已发布！', 
          groupID: 'musicfox-update', 
          openURL: 'https://github.com/AlanAlbert/musicfox',
        );
      }
    });
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
        displayPlayerUI();
        if (!Platform.isWindows && _playerStatus.status == Status.STOPPED) {
          Timer(Duration(milliseconds: 1000), () async {
            if (_playerStatus.status == Status.STOPPED) {
              _watch.stop();
              _watch.reset();
              await nextSong();
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
    Keys.bindKey(KeyName.SPACE).listen(play);
    Keys.bindKey('[').listen((_) => preSong());
    Keys.bindKey(']').listen((_) => nextSong());
    Keys.bindKey(',').listen((_) => likePlayingSong());
    Keys.bindKey('.').listen((_) => likePlayingSong(isLike: false));
    Keys.bindKeys(['w', 'W']).listen((_) => quitAndClear());
    Keys.bindKey('-').listen((_) => downVolume());
    Keys.bindKey('=').listen((_) => upVolumne());
    Keys.bindKey('/').listen((_) => trashPlayingSong());
    Keys.bindKey('p').listen((_) => changePlayMode());
    if (Platform.isWindows) {
      Keys.bindKey('o').listen((_) => intelligence());
      Keys.bindKey(';').listen((_) => likeSelectedSong());
      Keys.bindKey('\'').listen((_) => likeSelectedSong(isLike: false));
      Keys.bindKey('').listen((_) => trashSelectedSong());
    } else {
      Keys.bindKey('P').listen((_) => intelligence());
      Keys.bindKey('<').listen((_) => likeSelectedSong());
      Keys.bindKey('>').listen((_) => likeSelectedSong(isLike: false));
      Keys.bindKey('?').listen((_) => trashSelectedSong());
    }
  }

  /// 智能模式
  Future<void> intelligence([bool reservePlaylist = false]) async {
    if (!(_curMenuContent is PlaylistSongs)) return;
    var curMenu = _curMenuContent as PlaylistSongs;
    var playlistId = curMenu.playlistId;
    if (_window.selectIndex > _window.pageData.length - 1) return;
    Map selectedSong = _window.pageData[_window.selectIndex];
    if (!selectedSong.containsKey('id')) return;
    var loginStatus = await checkLogin(_window);
    if (!loginStatus) return;

    var playlist = request.Playlist();
    Map response = await playlist.getIntelligenceList(playlistId, selectedSong['id'], startMusicId: selectedSong['id']);
    response = validateResponse(_window, response);
    if (response['code'] == 301) {
      loginStatus = await login(_window);
      if (!loginStatus) return null;
      return intelligence(reservePlaylist);
    }
    if (!response.containsKey('data') || response['data'] == null) return;

    _isIntelligence = true;
    var songs = [];
    response['data'].forEach((song) {
      if (!song.containsKey('songInfo')) return;
      songs.add(song['songInfo']);
    });
    if (songs.isEmpty) return;

    if (reservePlaylist) {
      _playlist.addAll(songs);
      _curSongIndex++;
    } else {
      _playlist = songs;
      _curSongIndex = 0;
    }
    _playingMenuId = null;
    await playSong(_playlist[_curSongIndex]['id']);
  }

  /// 改变播放方式
  void changePlayMode() {
    if (_isIntelligence) return;
    switch (_playMode) {
      case PlaylistMode.ORDER: _playMode = PlaylistMode.LIST_LOOP;break;
      case PlaylistMode.LIST_LOOP: _playMode = PlaylistMode.SINGLE_LOOP;break;
      case PlaylistMode.SINGLE_LOOP: _playMode = PlaylistMode.SHUFFLE;break;
      case PlaylistMode.SHUFFLE: _playMode = PlaylistMode.ORDER;break;
      default: _playMode = PlaylistMode.ORDER;
    }
    displayPlayerUI(true);
    var cache = CacheFactory.produce();
    cache.set('playMode', PLAY_MODE[_playMode]);
  }

  /// 调小声音
  Future<void> downVolume() async {
    var player = await _player;
    player.downVolume();
  }

  /// 调大声音
  Future<void> upVolumne() async {
    var player = await _player;
    player.upVolumne();
  }

  /// 标记为不喜欢
  Future<void> trashPlayingSong() async {
    if (_playlist == null || 
      _curSongIndex > _playlist.length - 1) return;

    Map curSong = _playlist[_curSongIndex];
    if (curSong == null || !curSong.containsKey('id')) return;

    await trashSong(curSong);
  }

  /// 标记为不喜欢
  Future<void> trashSelectedSong() async {
    if (_window.pageData == null || 
      _window.selectIndex > _window.pageData.length - 1) return;

    Map selectedSong = _window.pageData[_window.selectIndex];
    if (selectedSong == null || !selectedSong.containsKey('id')) return;

    await trashSong(selectedSong);
  }

  /// 喜欢正在播放的歌曲
  Future<void> likePlayingSong({bool isLike = true}) async {
    if (_playlist == null || _curSongIndex > _playlist.length - 1) return;
    Map curSong = _playlist[_curSongIndex];
    
    var cache = CacheFactory.produce();
    Map user = cache.get('user');
    if (user == null) return;

    await likeSong(curSong, isLike: isLike);
  }

  /// 喜欢选中的歌曲
  Future<void> likeSelectedSong({bool isLike = true}) async {
    if (_window.pageData == null || _window.selectIndex > _window.pageData.length - 1) return;
    Map selectedSong = _window.pageData[_window.selectIndex];
    if (!_curMenuContent.isPlayable || !selectedSong.containsKey('id')) return;
    
    var cache = CacheFactory.produce();
    Map user = cache.get('user');
    if (user == null) return;

    await likeSong(selectedSong, isLike: isLike);
  }

  /// (不)喜欢歌曲
  Future<void> likeSong(Map curSong, {bool isLike = true}) async {
    if (curSong == null || !curSong.containsKey('id')) return;

    var cache = CacheFactory.produce();
    Map user = cache.get('user');
    if (user == null) return;

    var song = request.Song();
    Map response = await song.like(curSong['id'], isLike: isLike);
    if (response == null || !response.containsKey('code') || response['code'] != 200) return;

    var avatar = '';
    if (user.containsKey('avatar')) {
      avatar = user['avatar'];
    }

    String contentImage;
    if (curSong.containsKey('album')) {
      if (curSong['album'].containsKey('blurPicUrl') && curSong['album']['blurPicUrl'] != '') {
        contentImage = curSong['album']['blurPicUrl'];
      } else if (curSong['album'].containsKey('picUrl') && curSong['album']['picUrl'] != '') {
        contentImage = curSong['album']['picUrl'];
      }
    } else if (curSong.containsKey('al')) {
      if (curSong['al'].containsKey('blurPicUrl') && curSong['al']['blurPicUrl'] != '') {
        contentImage = curSong['al']['blurPicUrl'];
      } else if (curSong['al'].containsKey('picUrl') && curSong['al']['picUrl'] != '') {
        contentImage = curSong['al']['picUrl'];
      }
    }

    _notifier.send(
      '${curSong['name'] ?? ''}', 
      title: 'MusicFox', 
      subtitle: isLike ? '已添加到喜欢' : '已从喜欢中移除', 
      groupID: 'musicfox', 
      openURL: 'https://github.com/AlanAlbert/musicfox',
      appIcon: avatar,
      contentImage: contentImage
    );
  }

  /// 不喜欢私人FM推荐的这首歌
  Future<void> trashSong(Map curSong) async {
    if (curSong == null || !curSong.containsKey('id')) return;

    var cache = CacheFactory.produce();
    Map user = cache.get('user');
    if (user == null) return;

    var song = request.Song();
    Map response = await song.trashFMSong(curSong['id']);
    if (response == null || !response.containsKey('code') || response['code'] != 200) return;

    var avatar = '';
    if (user.containsKey('avatar')) {
      avatar = user['avatar'];
    }

    String contentImage;
    if (curSong.containsKey('album')) {
      if (curSong['album'].containsKey('blurPicUrl') && curSong['album']['blurPicUrl'] != '') {
        contentImage = curSong['album']['blurPicUrl'];
      } else if (curSong['album'].containsKey('picUrl') && curSong['album']['picUrl'] != '') {
        contentImage = curSong['album']['picUrl'];
      }
    } else if (curSong.containsKey('al')) {
      if (curSong['al'].containsKey('blurPicUrl') && curSong['al']['blurPicUrl'] != '') {
        contentImage = curSong['al']['blurPicUrl'];
      } else if (curSong['al'].containsKey('picUrl') && curSong['al']['picUrl'] != '') {
        contentImage = curSong['al']['picUrl'];
      }
    }

    _notifier.send(
      '${curSong['name'] ?? ''}', 
      title: 'MusicFox', 
      subtitle: '已标记为不喜欢', 
      groupID: 'musicfox', 
      openURL: 'https://github.com/AlanAlbert/musicfox',
      appIcon: avatar,
      contentImage: contentImage
    );
  }

  /// 退出
  void quit(WindowUI ui) {
    if (_playerContainer != null) _playerContainer.quit();
  }

  /// 退出并清理用户信息
  void quitAndClear() {
    Console.showCursor();
    _window.close();
    Console.resetAll();
    Console.eraseDisplay();
    var cookie = Directory(request.Request.cookieDir);
    if (cookie.existsSync()) {
      cookie.deleteSync(recursive: true);
    }
    var cache = CacheFactory.produce();
    cache.clear();
    quit(_window);
    exit(0);
  }

  /// 显示完欢迎界面后
  void enterMain(WindowUI ui) => displayPlayerUI();

  /// 显示播放器UI
  void displayPlayerUI([bool changeSong = false]) {
    if (_playlist == null || _playlist.isEmpty || _curSongIndex == null) return;

    // 歌词
    if (_playerTimer != null && Console.rows - 4 - _window.curMaxMenuRow > 3) {
      var startRow = ((Console.rows - 3 + _window.curMaxMenuRow) / 2).ceil();
      var preIndex = _curLyricIndex;
      if (_curSongLyric != null && _sortedLyricTime != null && _curSongLyric.isNotEmpty && _sortedLyricTime.isNotEmpty) {
        var curMilliseconds = _watch.elapsed.inMilliseconds;
        if (_curLyricIndex <= _sortedLyricTime.length - 2 && curMilliseconds >= _sortedLyricTime[_curLyricIndex+1]) _curLyricIndex++;
      } else if (_firstRenderLyric) {
        _curShowingLyrics = <String>['', '', '暂无歌词~', '', ''];
      }

      /// 刷新歌词
      if (preIndex != _curLyricIndex || _firstRenderLyric) {
        if (_firstRenderLyric) {
          _firstRenderLyric = false;
        } else {
          _curShowingLyrics = [
            _curLyricIndex > 1 ? _curSongLyric[_sortedLyricTime[_curLyricIndex-2]] : '',
            _curLyricIndex > 0 ? _curSongLyric[_sortedLyricTime[_curLyricIndex-1]] : '', 
            _curSongLyric[_sortedLyricTime[_curLyricIndex]], 
            _curLyricIndex < _sortedLyricTime.length - 1 ? _curSongLyric[_sortedLyricTime[_curLyricIndex+1]] : '',
            _curLyricIndex < _sortedLyricTime.length - 2 ? _curSongLyric[_sortedLyricTime[_curLyricIndex+2]] : '',
          ];
        }

        int lineNum;
        var lyrics = _curShowingLyrics;
        if (Console.rows - 4 - _window.curMaxMenuRow > 5) {
          lineNum = 5;
          startRow -= 2;
        } else {
          lineNum = 3;
          lyrics = lyrics.getRange(1, 4).toList();
          startRow -= 1;
        }

        for (var i = 0; i < lineNum; i++) {
          Console.moveCursor(row: startRow + i, column: 0);
          Console.write('\r');
          for (var j = 0; j < _window.startColumn + 2; j++) {
            Console.write(' ');
          }
          if (i == (lineNum / 2).floor()) {
            Console.write(ColorText().lightCyan(lyrics[i]).toString());
          } else {
            Console.write(ColorText().gray(lyrics[i]).toString());
          }
          for (var j = _window.startColumn + 2 + lyrics[i].length; j < Console.columns; j++) {
            Console.write(' ');
          }
        }
      }
      
    }

    // 歌曲名
    Console.moveCursor(row: Console.rows - 3, column: _window.startColumn - 6);
    var playMode = _isIntelligence ? '心动' : PLAY_MODE[_playMode];
    var status = _playerStatus.status == Status.PLAYING ? '♫  ♪ ♫  ♪' : '_ _ z Z Z';
    if (changeSong) {
      for (var i = 3; i > 0; i--) {
        Console.eraseLine(2); 
        Console.moveCursorDown();
      }
      Console.moveCursorUp(3);
    } else {
      Console.write('\r');
      for (var i = 1; i < _window.startColumn - 6; i++) {
        Console.write(' ');
      }
    }
    if (_curSongIndex <= _playlist.length - 1) {
      Console.write(ColorText()
        .magenta('[${playMode}] ')
        .setColor(_window.primaryColor).text('${status}  ${_playlist[_curSongIndex]['name']} ')
        .gray(getCurSongArtists()).toString());
    }

    // 进度条
    Console.moveCursor(row: Console.rows);
    _playerProgress != null ? _playerProgress.width = Console.columns - 14 : null;
    if (_curMusicInfo.duration != null && _playerProgress != null) {
      _playerProgress.update((_watch.elapsed.inSeconds / _curMusicInfo.duration.inSeconds * 100).round());
    }
    if (Console.columns > 30 && _curMusicInfo.duration != null) {
      var curTime = formatTime(_watch.elapsedMilliseconds);
      var totalTime = formatTime(_curMusicInfo.duration.inMilliseconds);
      Console.moveCursor(row: Console.rows, column: Console.columns - 12);
      Console.write(ColorText().setColor(_window.primaryColor).text('${curTime}/${totalTime}').toString());
    }
  }

  /// 获取当前歌曲的歌手
  String getCurSongArtists() {
    var artistName = '';
    if (_playlist[_curSongIndex].containsKey('artists')) {
        _playlist[_curSongIndex]['artists'].forEach((artist) {
          if (artist.containsKey('name')) {
            artistName = artistName == '' ? artist['name'] : '${artistName},${artist['name']}';
          }
        });
    } else if (_playlist[_curSongIndex].containsKey('ar')) {
        _playlist[_curSongIndex]['ar'].forEach((artist) {
          if (artist.containsKey('name')) {
            artistName = artistName == '' ? artist['name'] : '${artistName},${artist['name']}';
          }
        });
    }
    return '<${artistName}>';
  }

  /// 进入菜单
  Future<dynamic> beforeEnterMenu(WindowUI ui) async {
    try {
      var nextMenu = await _curMenuContent.getMenuContent(ui, ui.selectIndex);
      if (nextMenu == null) return;

      var menus = await nextMenu.getMenus(ui);
      if (menus != null && menus.isNotEmpty) {
        _menuContentStack.add(_curMenuContent);
        _curMenuContent = nextMenu;
        return menus;
      }
      var content = await nextMenu.getContent(ui);
      if (content == null) return;
      var row = ui.startRow;
      content.split('\n').forEach((line) {
        Console.moveCursor(row: row, column: ui.startColumn);
        Console.write(line);
        row++;
      });
      _menuContentStack.add(_curMenuContent);
      _curMenuContent = nextMenu;
      return [];
    } on SocketException {
      error('网络错误~, 请稍后重试');
    } on ResponseException catch (e) {
      error(e.toString());
    }
    return;
  }

  /// 返回菜单
  Future<void> beforeBackMenu(WindowUI ui) {
    if (_menuContentStack.isEmpty) return null;
    _curMenuContent = _menuContentStack.removeLast();
    return Future.value();
  }

  /// 翻页
  Future<List<String>> beforeNextPage(WindowUI ui) async {
    return Future.value([]);
  }

  /// 空格监听
  void play(_) async {
    var inPlaying = inPlayingMenu();
    var songs = ((await inPlaying) && !_curMenuContent.isResetPlaylist) ? _playlist : _window.pageData;
    
    var player = (await _player);
    var index = _window.selectIndex;
    if (_curMenuContent == null || !_curMenuContent.isPlayable || songs == null || index > songs.length - 1) {
      if (_playerStatus.status == Status.PAUSED) {
        if (Platform.isWindows) _playerStatus.setStatus(STATUS_VALUES[Status.PLAYING]);
        player.resume();
        if (_watch != null) _watch.start();
        if (Platform.isWindows) _playerStatus.setStatus(STATUS_VALUES[Status.PLAYING]);
      } else if (_playerStatus.status == Status.PLAYING) {
        if (Platform.isWindows) _playerStatus.setStatus(STATUS_VALUES[Status.PAUSED]);
        player.pause();
        if (_watch != null) _watch.stop();
        if (Platform.isWindows) _playerStatus.setStatus(STATUS_VALUES[Status.PAUSED]);
      } else {
        if (_curSongIndex > _playlist.length - 1 || !_playlist[_curSongIndex].containsKey('id')) return;
        await playSong(_playlist[_curSongIndex]['id']);
      }
      return;
    }
    
    _curSongIndex = index;
    Map songInfo = songs[_curSongIndex];
    if (!songInfo.containsKey('id')) return;

    if ((await inPlaying) && _curMusicInfo.id == songInfo['id']) {
      if (_playerStatus.status == Status.PAUSED) {
        player.resume();
        if (_watch != null) _watch.start();
        if (Platform.isWindows) _playerStatus.setStatus(STATUS_VALUES[Status.PLAYING]);
      } else {
        player.pause();
        if (_watch != null) _watch.stop();
        if (Platform.isWindows) _playerStatus.setStatus(STATUS_VALUES[Status.PAUSED]);
      }
    } else {
      _playingMenuId = _curMenuContent.getMenuId();
      _playlist = songs;
      _isIntelligence = false;
      await playSong(songInfo['id']);
    }
  }

  /// 获取bottom out content
  Future<BottomOutContent> getBottomOutContent() async {
    try {
      var bottomOutContent = await _curMenuContent.bottomOut(_window);
      if (bottomOutContent != null) return bottomOutContent;
    } on SocketException {
      error('网络错误~, 请稍后重试');
    } on ResponseException catch (e) {
      error(e.toString());
    }
    return null;
  }

  /// 下一曲
  Future<void> nextSong() async {
    if (_playlist == null || _curSongIndex >= _playlist.length - 1) {
      if (_isIntelligence) {
        await intelligence(true);
      }
      var content = await getBottomOutContent();
      if (content != null) {
        if (content.appendMenus != null && content.appendMenus.isNotEmpty) {
          _window.menu.addAll(content.appendMenus);
        }
        if (content.appendSongs != null && content.appendSongs.isNotEmpty) {
          _playlist.addAll(content.appendSongs);
        }
      }
    };
    var songs = _playlist;
    switch (_playMode) {
      case PlaylistMode.LIST_LOOP:
        _curSongIndex = _curSongIndex >= songs.length - 1 ? 0 : _curSongIndex + 1;
        break;
      case PlaylistMode.SINGLE_LOOP:
        break;
      case PlaylistMode.SHUFFLE:
        _curSongIndex = Random().nextInt(songs.length - 1);
        break;
      case PlaylistMode.ORDER:
        if (_curSongIndex >= songs.length - 1) return;
        _curSongIndex++;
        break;
    }
    if (_curSongIndex > songs.length - 1) return;
    Map songInfo = songs[_curSongIndex];
    if (!songInfo.containsKey('id')) return;
    await playSong(songInfo['id']);
  }

  /// 上一曲
  Future<void> preSong() async {
    if (_playlist == null) return;
    switch (_playMode) {
      case PlaylistMode.LIST_LOOP:
        _curSongIndex = _curSongIndex <= 0 ? _playlist.length - 1 : _curSongIndex - 1;
        break;
      case PlaylistMode.SINGLE_LOOP:
        break;
      case PlaylistMode.SHUFFLE:
        _curSongIndex = Random().nextInt(_playlist.length - 1);
        break;
      case PlaylistMode.ORDER:
        if (_curSongIndex <= 0) return;
        _curSongIndex--;
        break;
    }
    Map songInfo = _playlist[_curSongIndex];
    if (!songInfo.containsKey('id')) return;
    await playSong(songInfo['id']);
  }

  /// 播放列表对比
  bool comparePlaylist(List p1, List p2) {
    if (p1 == null || p2 == null) return false;
    if (p1.length != p2.length) return false;
    var length = min(p1.length - 1, 10);
    for (var i = 0; i < length; i++) {
      if (!p1[i].containsKey('id') || !p2[i].containsKey('id')) return false;
      if (p1[i]['id'] != p2[i]['id']) return false;
    }
    return true;
  }

  /// 定位到相应的播放歌曲
  Future<void> locateSong() async {
    if (!(await inPlayingMenu()) || !comparePlaylist(_playlist, _window.pageData)) return;
    var pageDelta = (_curSongIndex / _window.menuPageSize).floor() - (_window.menuPage - 1);
    if (pageDelta > 0) {
      for (var i = 0; i < pageDelta; i++) {
        await _window.nextPage();
      }
    } else if (pageDelta < 0) {
      for (var i = 0; i > pageDelta; i--) {
        await _window.prePage();
      }
    }
    _window.selectIndex = _curSongIndex;
    _window.displayList();
  }

  /// 发送通知
  void notify() {
    if (_curSongIndex > _playlist.length - 1 || !_playlist[_curSongIndex].containsKey('name')) return;
    var songName = _playlist[_curSongIndex]['name'];
    var artist = getCurSongArtists();
    String contentImage;
    if (_playlist[_curSongIndex].containsKey('album')) {
      if (_playlist[_curSongIndex]['album'].containsKey('blurPicUrl') && _playlist[_curSongIndex]['album']['blurPicUrl'] != '') {
        contentImage = _playlist[_curSongIndex]['album']['blurPicUrl'];
      } else if (_playlist[_curSongIndex]['album'].containsKey('picUrl') && _playlist[_curSongIndex]['album']['picUrl'] != '') {
        contentImage = _playlist[_curSongIndex]['album']['picUrl'];
      }
    } else if (_playlist[_curSongIndex].containsKey('al')) {
      if (_playlist[_curSongIndex]['al'].containsKey('blurPicUrl') && _playlist[_curSongIndex]['al']['blurPicUrl'] != '') {
        contentImage = _playlist[_curSongIndex]['al']['blurPicUrl'];
      } else if (_playlist[_curSongIndex]['al'].containsKey('picUrl') && _playlist[_curSongIndex]['al']['picUrl'] != '') {
        contentImage = _playlist[_curSongIndex]['al']['picUrl'];
      }
    }
    var cache = CacheFactory.produce();
    Map user = cache.get('user');
    var avatar = '';
    if (user != null && user.containsKey('avatar')) {
      avatar = user['avatar'];
    }
    _notifier.send(
      '${songName} - ${artist}', 
      title: 'MusicFox', 
      subtitle: '正在播放: ${songName}', 
      groupID: 'musicfox', 
      openURL: 'https://github.com/AlanAlbert/musicfox',
      appIcon: avatar,
      contentImage: contentImage
    );
  }

  /// 播放指定音乐
  Future<void> playSong(int songId) async {
    _playerStatus.setStatus(STATUS_VALUES[Status.PLAYING]);
    await locateSong();
    displayPlayerUI(true);
    notify();
    _watch.stop();
    _watch.reset();
    _watch.start();
    var songRequest = request.Song();
    Map songUrl = await songRequest.getSongUrlByWeb(songId);
    songUrl = songUrl['data'][0];
    if (!songUrl.containsKey('url') || songUrl['url'] == null) {
      await nextSong();
      return;
    };
    (await _player).playWithoutList(songUrl['url']);
    _curMusicInfo.setId(songId);
    
    _curSongLyric = await getLyric(songId);
    _curShowingLyrics = <String>['', '', '', '', ''];
    if (_curSongLyric != null) {
      _sortedLyricTime = _curSongLyric.keys.toList()..sort();
    }
    _curLyricIndex = 0;
    _firstRenderLyric = true;

    var duration = 0;
    if (_playlist[_curSongIndex].containsKey('duration')) {
      duration = _playlist[_curSongIndex]['duration'];
    } else if (_playlist[_curSongIndex].containsKey('dt')) {
      duration = _playlist[_curSongIndex]['dt'];
    }
    _curMusicInfo.setDuration(Duration(milliseconds: duration));
    var cache = CacheFactory.produce();
    cache.set('progress', {
      'curSongIndex': _curSongIndex,
      'playlist': _playlist,
      'playingMenuId': _playingMenuId
    });

    // 播放器进度条
    _playerProgress = RainbowProgress(
      completeChar: '_',
      forwardChar: '_',
      leftDelimiter: '',
      rightDelimiter: '',
      showPercent: false,
      width: Console.columns > 30 ? Console.columns - 14 : Console.columns,
      rainbow: true);
    _playerProgress.update(0);
    if (_playerTimer != null) _playerTimer.cancel();
    _playerTimer = Timer.periodic(Duration(milliseconds: 400), (timer) async {
      displayPlayerUI();
      if (_watch.elapsedMilliseconds >= _curMusicInfo.duration.inMilliseconds) {
        timer.cancel();
        _watch..stop()..reset();
        if (Platform.isWindows) {
          await nextSong();
        }
      }
    });
  }

  /// 是否在播放列表
  Future<bool> inPlayingMenu() async {
    if (_playingMenuId == null) return false;
    return _curMenuContent.getMenuId() == _playingMenuId;
  }

}
