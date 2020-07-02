import 'package:musicfox/ui/menu_content/bottom_out_content.dart';
import 'package:colorful_cmd/component.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';
import 'package:musicfox/ui/menu_content/new_albums.dart';
import 'package:musicfox/ui/menu_content/newest_albums.dart';

class Albums implements IMenuContent {
  final List<IMenuContent> MENUS = [
    NewAlbums(),
    NewestAlbums(),
  ];

  @override
  Future<BottomOutContent> bottomOut(WindowUI ui) => null;

  @override
  Future<String> getContent(WindowUI ui) => null;

  @override
  Future<IMenuContent> getMenuContent(WindowUI ui, int index) {
    if (index > MENUS.length - 1) return null;
    return Future.value(MENUS[index]);
  }

  @override
  Future<List<String>> getMenus(WindowUI ui) {
    return Future.value([
      '新碟上架',
      '最新专辑',
    ]);
  }

  @override
  bool get isPlayable => false;

  @override
  bool get isResetPlaylist => false;
  
}