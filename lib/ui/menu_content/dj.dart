import 'package:musicfox/ui/bottom_out_content.dart';

import 'package:colorful_cmd/component.dart';
import 'package:musicfox/ui/menu_content/dj_recommend.dart';

import 'i_menu_content.dart';

List<IMenuContent> DJ_MENU_CONTENTS = [
  DjRecommend(),
];

class Dj implements IMenuContent {
  @override
  Future<BottomOutContent> bottomOut(WindowUI ui) => null;

  @override
  Future<String> getContent(WindowUI ui) => null;

  @override
  Future<IMenuContent> getMenuContent(WindowUI ui, int index) {
    return Future.value(DJ_MENU_CONTENTS[index]);
  }

  @override
  String getMenuId() => 'Dj()';

  @override
  Future<List<String>> getMenus(WindowUI ui) => Future.value([
    '推荐电台',
    '今日优选',
    '热门电台',
    '新晋电台',
    '电台分类',
    '节目榜',
    '24小时节目榜',
    '24小时主播榜',
    '最热主播榜',
  ]);

  @override
  bool get isPlayable => false;

  @override
  bool get isResetPlaylist => false;
  
}