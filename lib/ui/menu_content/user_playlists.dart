import 'package:colorful_cmd/component.dart';
import 'package:musicfox/cache/i_cache.dart';
import 'package:musicfox/ui/bottom_out_content.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';
import 'package:musicfox/ui/menu_content/playlist_songs.dart';
import 'package:musicfox/utils/function.dart';
import 'package:netease_music_request/request.dart';

class UserPlaylists implements IMenuContent {

  static int _userId;
  static List _playlists;

  UserPlaylists([int userId]) {
    if (userId == null) {
      var cache = CacheFactory.produce();
      var user = cache.get('user');
      if (user != null && user.containsKey('userId')) userId = user['userId'];
    }
    if (_userId != userId) _playlists = null;
    _userId = userId;
  }

  @override
  bool get isPlayable => false;

  @override
  bool get isResetPlaylist => false;

  @override
  Future<String> getContent(WindowUI ui) => Future.value('');

  @override
  Future<IMenuContent> getMenuContent(WindowUI ui, int index) {
    if (ui.pageData.length - 1 < index || !ui.pageData[index].containsKey('id')) return null;
    return Future.value(PlaylistSongs(ui.pageData[index]['id']));
  }

  @override
  Future<List<String>> getMenus(WindowUI ui) async {
    if (_playlists == null || _playlists.isEmpty) {
      await checkLogin(ui);
      if (_userId == null) {
        var cache = CacheFactory.produce();
        var user = cache.get('user');
        if (user != null && user.containsKey('userId')) {
          _userId = user['userId'];
        } else {
          return [];
        }
      };
      
      var playlist = Playlist();
      Map response = await playlist.gteUserPlaylists(_userId);
      response = validateResponse(response);

      _playlists = response.containsKey('playlist') ? response['playlist'] : [];
    }

    ui.pageData = _playlists;

    var res = <String>[];
    _playlists.forEach((item) {
      var name = '';
      if (item.containsKey('name')) {
        name = item['name'];
      }
      res.add(name);
    });

    return Future.value(res);
  }

  @override
  Future<BottomOutContent> bottomOut(WindowUI ui) => null;
  
}