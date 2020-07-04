import 'package:musicfox/ui/bottom_out_content.dart';
import 'package:colorful_cmd/component.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';
import 'package:musicfox/ui/menu_content/search_result.dart';

class SearchType implements IMenuContent {

  static const List<int> SEARCH_TYPE = [
    1,    // 单曲
    10,   // 专辑
    100,  // 歌手
    1000, // 歌单
    1002, // 用户
    1006, // 歌词
    1009, // 电台
  ];

  static const List<String> SEARCH_TYPE_NAME = [
    '歌曲',
    '专辑',
    '歌手',
    '歌单',
    '用户',
    '歌词',
    '电台',
  ];

  @override
  Future<BottomOutContent> bottomOut(WindowUI ui) => null;

  @override
  Future<String> getContent(WindowUI ui) => null;

  @override
  Future<IMenuContent> getMenuContent(WindowUI ui, int index) {
    if (index > SEARCH_TYPE.length - 1) return null;
    return Future.value(SearchResult(ui, SEARCH_TYPE[index], SEARCH_TYPE_NAME[index]));
  }

  @override
  Future<List<String>> getMenus(WindowUI ui) {
    return Future.value(SEARCH_TYPE_NAME);
  }

  @override
  bool get isPlayable => false;

  @override
  bool get isResetPlaylist => false;
  
}