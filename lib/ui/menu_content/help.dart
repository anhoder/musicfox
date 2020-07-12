import 'package:colorful_cmd/utils.dart';
import 'package:musicfox/ui/bottom_out_content.dart';
import 'package:colorful_cmd/component.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';

class Help implements IMenuContent {
  @override
  Future<BottomOutContent> bottomOut(WindowUI ui) => null;

  @override
  Future<String> getContent(WindowUI ui) => null;

  @override
  Future<IMenuContent> getMenuContent(WindowUI ui, int index) => null;

  @override
  String getMenuId() => 'Help()';

  @override
  Future<List<String>> getMenus(WindowUI ui) {
    return Future.value([
      '${ColorText().cyan('[h/H/LEFT]').toString()} ${ColorText().blue('左').toString()}',
      '${ColorText().cyan('[l/L/RIGHT]').toString()} ${ColorText().blue('右').toString()}',
      '${ColorText().cyan('[k/K/UP]').toString()} ${ColorText().blue('上').toString()}',
      '${ColorText().cyan('[j/J/DOWN]').toString()} ${ColorText().blue('下').toString()}',
      '${ColorText().cyan('[q/Q]').toString()} ${ColorText().blue('退出').toString()}',
      '${ColorText().cyan('[space]').toString()} ${ColorText().blue('暂停/播放').toString()}',
      '${ColorText().cyan('[[]').toString()} ${ColorText().blue('上一曲').toString()}',
      '${ColorText().cyan('[]]').toString()} ${ColorText().blue('下一曲').toString()}',
      '${ColorText().cyan('[-]').toString()} ${ColorText().blue('减小音量').toString()}',
      '${ColorText().cyan('[=]').toString()} ${ColorText().blue('加大音量').toString()}',
      '${ColorText().cyan('[n/N/ENTER]').toString()} ${ColorText().blue('进入选中的菜单项').toString()}',
      '${ColorText().cyan('[b/B/ESC]').toString()} ${ColorText().blue('返回上级菜单').toString()}',
      '${ColorText().cyan('[w/W]').toString()} ${ColorText().blue('退出并退出登录').toString()}',
      '${ColorText().cyan('[p]').toString()} ${ColorText().blue('切换播放方式').toString()}',
      '${ColorText().cyan('[P]').toString()} ${ColorText().blue('心动模式(仅在歌单中时有效)').toString()}',
      '${ColorText().cyan('[,]').toString()} ${ColorText().blue('喜欢当前播放歌曲').toString()}',
      '${ColorText().cyan('[<]').toString()} ${ColorText().blue('喜欢当前选中歌曲').toString()}',
      '${ColorText().cyan('[.]').toString()} ${ColorText().blue('当前播放歌曲移除出喜欢').toString()}',
      '${ColorText().cyan('[>]').toString()} ${ColorText().blue('当前选中歌曲移除出喜欢').toString()}',
      '${ColorText().cyan('[/]').toString()} ${ColorText().blue('标记当前播放歌曲为不喜欢').toString()}',
      '${ColorText().cyan('[?]').toString()} ${ColorText().blue('标记当前选中歌曲为不喜欢').toString()}',
    ]);
  }

  @override
  bool get isPlayable => false;

  @override
  bool get isResetPlaylist => false;
  
}