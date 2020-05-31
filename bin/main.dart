
import 'package:colorful_cmd/component.dart';
import 'package:musicfox/lang/chinese.dart';

void main(List<String> arguments) {
  var ui = WindowUI(
    name: 'MusicFox', 
    welcomeMsg: 'MUSICFOX', 
    menu: <String>[
      '排行榜',
      '艺术家',
      '新碟上架',
      '精选歌单',
      '我的歌单',
      '主播电台',
      '每日推荐歌曲',
      '每日推荐歌单',
      '私人FM',
      '搜索',
    ],
    defaultMenuTitle: '网易云音乐',
    beforeEnterMenu: (ui) => [],
    lang: Chinese()
  );
  ui.display();
}
