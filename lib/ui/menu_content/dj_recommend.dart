import 'package:musicfox/ui/bottom_out_content.dart';
import 'package:colorful_cmd/component.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';

class DjRecommend implements IMenuContent {
  @override
  Future<BottomOutContent> bottomOut(WindowUI ui) => null;

  @override
  Future<String> getContent(WindowUI ui) => null;

  @override
  Future<IMenuContent> getMenuContent(WindowUI ui, int index) {
    // TODO: implement getMenuContent
    throw UnimplementedError();
  }

  @override
  String getMenuId() => 'DjRecommend()';

  @override
  Future<List<String>> getMenus(WindowUI ui) {
    // TODO: implement getMenus
    throw UnimplementedError();
  }

  @override
  bool get isPlayable => throw UnimplementedError();

  @override
  // TODO: implement isResetPlaylist
  bool get isResetPlaylist => throw UnimplementedError();
  
}