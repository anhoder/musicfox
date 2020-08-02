import 'dart:convert';
import 'dart:io';

import 'package:colorful_cmd/component.dart';
import 'package:colorful_cmd/utils.dart';
import 'package:console/console.dart';
import 'package:musicfox/cache/i_cache.dart';
import 'package:musicfox/ui/login.dart';
import 'package:netease_music_request/request.dart';

/// 检查是否登录，未登录调起登录
Future<bool> checkLogin(WindowUI ui) async {
  var cache = CacheFactory.produce();
  var user = cache.get('user');
  if (user == null) return await login(ui);
  return true;
}

/// 验证响应
Map validateResponse(WindowUI ui, Map response) {
  if (!(response['code'] is int)) {
    response['code'] = int.tryParse(response['code']);
  }
  if (response['code'] == null) return null;
  if (response['code'] == 400) {
    ui.earseMenu();
    Console.moveCursor(row: ui.startRow, column: ui.startColumn);
    Console.write(ColorText().gold('你到底要啥玩意(╯▔皿▔)╯').toString());
    return null;
  } else {
    if (response['code'] >= 500) {
      ui.earseMenu();
      Console.moveCursor(row: ui.startRow, column: ui.startColumn);
      Console.write(ColorText().gray('服务器拍了拍你的脑袋，说：“').darkRed('${response['msg'] ?? ''}').gray('”').toString());
      return null;
    }
  }
  return response;
}

/// 格式化秒
String formatTime(int milliseconds) {
  var m = (milliseconds / 60000).floor();
  var s = ((milliseconds / 1000) % 60).floor();
  return '${m >= 10 ? m : '0${m}'}:${s >= 10 ? s : '0${s}'}';
}

/// 获取歌名列表
List<String> getListFromSongs(List songs) {
  var res = <String>[];
  songs.forEach((item) {
    var name = '';
    if (item.containsKey('name')) {
      var artistName = '';
      name = item['name'];
      List artists = item.containsKey('artists') ? item['artists'] : [];
      if (artists.isEmpty) artists = item.containsKey('ar') ? item['ar'] : [];
      artists.forEach((artist) {
        if (artist.containsKey('name')) {
          artistName = artistName == '' ? artist['name'] : '${artistName},${artist['name']}';
        }
      });
      artistName = '<${artistName}>';
      if (artistName != '<>') name = '${name} ' + ColorText().gray(artistName).toString();
    }
    res.add(name);
  });
  return res;
}

/// 获取专辑名列表
List<String> getListFromAlbums(List albums) {
  var res = <String>[];
  albums.forEach((album) {
    var name = album.containsKey('name') ? album['name'] : '';
    var artistName = album.containsKey('artist') ? album['artist']['name'] : '';
    artistName = '<${artistName}>';
    if (artistName != '<>') name = '${name} ' + ColorText().gray(artistName).toString();

    res.add(name);
  });
  return res;
}

/// 获取歌手列表
List<String> getListFromArtists(List artists) {
  var res = <String>[];
  artists.forEach((artist) {
    var name = artist.containsKey('name') ? artist['name'] : '';
    res.add(name);
  });
  return res;
}

/// 获取歌单列表
List<String> getListFromPlaylists(List playlists) {
  var res = <String>[];
  playlists.forEach((item) {
    var name = item.containsKey('name') ? item['name'] : '';
    res.add(name);
  });
  return res;
}

/// 获取用户列表
List<String> getListFromUsers(List users) {
  var res = <String>[];
  users.forEach((item) {
    var name = item.containsKey('nickname') ? item['nickname'] : '';
    if (item.containsKey('userId')) {
      var userId = ColorText().gray('(${item['userId']})');
      name = '${name} ${userId}';
    }
    res.add(name);
  });
  return res;
}

/// 获取电台列表
List<String> getListFromDjs(List djs) {
  var res = <String>[];
  djs.forEach((item) {
    var name = item.containsKey('name') ? item['name'] : '';
    if (item.containsKey('dj')) {
      if (item['dj'].containsKey('nickname') && item['dj']['nickname'] != '') {
        var nickname = ColorText().gray('<${item['dj']['nickname']}>').toString();
        name = '${name} ${nickname}';
      }
    }
    res.add(name);
  });
  return res;
}

/// 获取排行榜
List<String> getListFromRanks(List ranks) {
  var res = <String>[];
  ranks.forEach((item) {
    var name = item.containsKey('name') ? item['name'] : '';
    if (item.containsKey('updateFrequency')) {
      var updateTime = ColorText().gray('<${item['updateFrequency']}>').toString();
      name = '${name} ${updateTime}';
    }
    res.add(name);
  });
  return res;
}

/// 获取DJ分类
List<String> getListFromDjCats(List djCats) {
  var res = <String>[];
  djCats.forEach((item) {
    var name = item.containsKey('name') ? item['name'] : '';
    res.add(name);
  });
  return res;
}


/// 获取歌词
Future<Map<int, String>> getLyric(int songId) async {
  var song = Song();
  Map response = await song.getLyric(songId);
  if (response.containsKey('lrc') && response['lrc'].containsKey('lyric') && response['lrc']['lyric'] != null) {
    String lyric = response['lrc']['lyric'];
    var res = <int, String>{};
    lyric.split('\n').forEach((item) {
      var start = 0;
      var last = item.lastIndexOf(']');
      if (last < 0) return;
      var str = item;
      while (start < last) {
        str = str.substring(start);
        var left = str.indexOf('[');
        var right = str.indexOf(']');
        if (left < 0 && right < 0) break;
        var time = str.substring(left + 1, right).split(':');
        if (time.length > 1 && time[0] != '' && time[1] != '') {
          var minutes = int.tryParse(time[0]);
          var seconds = double.tryParse(time[1]);
          if (minutes == null || seconds == null) return;
          var millseconds = (minutes * 60000 + seconds * 1000).toInt();
          res[millseconds] = item.substring(last + 1).trim();
        }
        start = right + 1;
      }
    });
    return res;
  }
  return null;
}

/// 签到
void signin(NotifierProxy notifier) {
  var cache = CacheFactory.produce();
  Map user = cache.get('user');
  var avatar = '';
  if (user != null && user.containsKey('avatar')) {
    avatar = user['avatar'];
  }

  var userRequest = User();
  // 手机签到
  userRequest.sign(type: 0).then((response) {
    if (response == null) return;
    if (response['code'] == 200) {
      notifier.send(
        '获得${response['point']}云贝', 
        title: 'MusicFox', 
        subtitle: '手机端签到成功', 
        groupID: 'musicfox-mobile-sign', 
        openURL: 'https://github.com/AlanAlbert/musicfox',
        appIcon: avatar
      );
    }
  });

  // PC签到
  userRequest.sign(type: 1).then((response) {
    if (response == null) return;
    if (response['code'] == 200) {
      notifier.send(
        '获得${response['point']}云贝', 
        title: 'MusicFox', 
        subtitle: 'PC端签到成功', 
        groupID: 'musicfox-pc-sign', 
        openURL: 'https://github.com/AlanAlbert/musicfox',
        appIcon: avatar
      );
    }
  });
}

/// 获取最新的Tag
Future<String> getLatestTag() async {
  try {
    var httpClient = HttpClient();
    var uri = Uri.https('api.github.com', '/repos/AlanAlbert/musicfox/releases/latest');
    var request = await httpClient.getUrl(uri);
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    Map res = json.decode(responseBody);
    if (res.containsKey('tag_name')) {
      return res['tag_name'];
    }
    return '';
  } catch (e) {
    return '';
  }

}