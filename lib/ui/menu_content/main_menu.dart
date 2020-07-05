import 'package:musicfox/ui/bottom_out_content.dart';
import 'package:colorful_cmd/component.dart';
import 'package:musicfox/ui/main_ui.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';

class MainMenu implements IMenuContent {
  @override
  Future<BottomOutContent> bottomOut(WindowUI ui) => null;

  @override
  Future<String> getContent(WindowUI ui) => null;

  @override
  Future<IMenuContent> getMenuContent(WindowUI ui, int index) {
    if (index > MENU_CONTENTS.length - 1) return null;
    return Future.value(MENU_CONTENTS[index]);
  }

  @override
  String getMenuId() => 'MainMenu()';

  @override
  Future<List<String>> getMenus(WindowUI ui) {
    return Future.value([
      '每日推荐歌曲',
      '每日推荐歌单',
      '我的歌单',
      '私人FM',
      '专辑列表',
      '搜索',
      '排行榜',
      '精选歌单',
      '热门歌手',
      '主播电台',
      '云盘',
    ]);
  }

  @override
  bool get isPlayable => false;

  @override
  bool get isResetPlaylist => false;
  
}