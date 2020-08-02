import 'package:musicfox/ui/bottom_out_content.dart';

import 'package:colorful_cmd/component.dart';
import 'package:musicfox/ui/menu_content/dj_cat.dart';
import 'package:musicfox/ui/menu_content/dj_daily_recommend.dart';
import 'package:musicfox/ui/menu_content/dj_hot.dart';
import 'package:musicfox/ui/menu_content/dj_mine.dart';
import 'package:musicfox/ui/menu_content/dj_new.dart';
import 'package:musicfox/ui/menu_content/dj_program_24rank.dart';
import 'package:musicfox/ui/menu_content/dj_program_rank.dart';
import 'package:musicfox/ui/menu_content/dj_recommend.dart';

import 'i_menu_content.dart';

List<IMenuContent> DJ_MENU_CONTENTS = [
  DjMine(),
  DjRecommend(),
  DjDailyRecommend(),
  DjHot(),
  DjNew(),
  DjCat(),
  DjProgramRank(),
  DjProgram24Rank(),
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
    '我的订阅',
    '推荐电台',
    '今日优选',
    '热门电台',
    '新晋电台',
    '电台分类',
    '节目榜',
    '24小时节目榜',
  ]);

  @override
  bool get isPlayable => false;

  @override
  bool get isResetPlaylist => false;
  
  @override
  bool get isDjMenu => false;
}