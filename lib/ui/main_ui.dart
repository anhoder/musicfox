import 'package:colorful_cmd/component.dart';
import 'package:musicfox/lang/chinese.dart';

class MainUI {
  WindowUI window;

  MainUI() {
    window = WindowUI(
      name: 'MusicFox', 
      welcomeMsg: 'MUSICFOX', 
      menu: <String>[
        '每日推荐歌曲',
        '每日推荐歌单',
        '我的歌单',
        '私人FM',
        '新歌上架',
        '搜索',
        '排行榜',
        '精选歌单',
        '热门歌手',
        '主播电台',
        '云盘',
      ],
      defaultMenuTitle: '网易云音乐',
      beforeEnterMenu: (ui) => [],
      lang: Chinese()
    );
  }

  void display() {
    window.display();
  }
}