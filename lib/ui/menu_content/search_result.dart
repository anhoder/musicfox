import 'package:colorful_cmd/utils.dart';
import 'package:musicfox/ui/bottom_out_content.dart';
import 'package:colorful_cmd/component.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';
import 'package:musicfox/ui/menu_content/search_type.dart';
import 'package:musicfox/ui/search.dart';
import 'package:musicfox/utils/function.dart';

class SearchResult implements IMenuContent {

  int _type;
  String _menu;

  static const Map SEARCH_TYPE_KEYS = {
    1:    'songs',        // 单曲
    10:   'albums',       // 专辑
    100:  'artists',      // 歌手
    1000: 'playlists',    // 歌单
    1002: 'userprofiles',  // 用户
    1006: 'songs',        // 歌词
    1009: 'djRadios',     // 电台
  };

  SearchResult(int index) {
    _type = SearchType.SEARCH_TYPE[index];
    _menu = SearchType.SEARCH_TYPE_NAME[index];
  }

  @override
  Future<BottomOutContent> bottomOut(WindowUI ui) => null;

  @override
  Future<String> getContent(WindowUI ui) => null;

  @override
  Future<IMenuContent> getMenuContent(WindowUI ui, int index) => null;

  @override
  Future<List<String>> getMenus(WindowUI ui) async {
    var response = await search(ui, _type, _menu);
    Map result = response['result'];

    if (!result.containsKey(SEARCH_TYPE_KEYS[_type])) return [];
    var data = result[SEARCH_TYPE_KEYS[_type]];
    ui.pageData = data;

    var res = <String>[];
    switch (SEARCH_TYPE_KEYS[_type]) {
      case 'songs': 
        res = getListFromSongs(data);
        break;
      case 'albums':
        res = getListFromAlbums(data);
        break;
    }

    return res;
  }

  @override
  bool get isPlayable => SEARCH_TYPE_KEYS[_type] == 'songs';

  @override
  bool get isResetPlaylist => false;
  
}