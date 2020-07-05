import 'package:musicfox/ui/bottom_out_content.dart';
import 'package:colorful_cmd/component.dart';
import 'package:musicfox/ui/menu_content/album_content.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';
import 'package:musicfox/ui/menu_content/playlist_songs.dart';
import 'package:musicfox/ui/menu_content/search_type.dart';
import 'package:musicfox/ui/menu_content/user_playlists.dart';
import 'package:musicfox/ui/search.dart';
import 'package:musicfox/utils/function.dart';

class SearchResult implements IMenuContent {

  int _type;
  List _data;
  
  final String _menu;
  final WindowUI _ui;

  static const Map SEARCH_TYPE_KEYS = {
    1:    'songs',        // 单曲
    10:   'albums',       // 专辑
    100:  'artists',      // 歌手
    1000: 'playlists',    // 歌单
    1002: 'userprofiles',  // 用户
    1006: 'songs',        // 歌词
    1009: 'djRadios',     // 电台
  };

  SearchResult(this._ui, int type, this._menu) {
    _type = type;
  }

  @override
  Future<BottomOutContent> bottomOut(WindowUI ui) => null;

  @override
  Future<String> getContent(WindowUI ui) => null;

  @override
  Future<IMenuContent> getMenuContent(WindowUI ui, int index) {
    if (_ui.menuStack.length < 2 || _data == null) return null;
    switch (SEARCH_TYPE_KEYS[_type]) {
      case 'albums':
        return Future.value(AlbumContent(_data[index]['id']));
      case 'playlists':
        return Future.value(PlaylistSongs(_data[index]['id']));
      case 'userprofiles':
        return Future.value(UserPlaylists(_data[index]['userId']));
    }
    return null;
  }

  @override
  Future<List<String>> getMenus(WindowUI ui) async {
    var response = await search(ui, _type, _menu);
    Map result = response['result'];

    if (!result.containsKey(SEARCH_TYPE_KEYS[_type])) return [];
    _data = result[SEARCH_TYPE_KEYS[_type]];
    ui.pageData = _data;

    switch (SEARCH_TYPE_KEYS[_type]) {
      case 'songs': 
        return getListFromSongs(_data);
      case 'albums':
        return getListFromAlbums(_data);
      case 'artists':
        return getListFromArtists(_data);
      case 'playlists':
        return getListFromPlaylists(_data);
      case 'userprofiles':
        return getListFromUsers(_data);
      case 'djRadios':
        return getListFromDjs(_data);
    }

    return [];
  }

  @override
  bool get isPlayable {
    if (_ui.menuStack.isEmpty) return false;
    var index = _ui.menuStack.last.index;
    return SEARCH_TYPE_KEYS[SearchType.SEARCH_TYPE[index]] == 'songs';
  }

  @override
  bool get isResetPlaylist => true;
  
  @override
  String getMenuId() => 'SearchResult(${_type})';

}