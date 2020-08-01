import 'package:musicfox/ui/bottom_out_content.dart';
import 'package:colorful_cmd/component.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';

abstract class IDjMenuContent implements IMenuContent {

  @override
  Future<BottomOutContent> bottomOut(WindowUI ui);

  @override
  Future<String> getContent(WindowUI ui);

  @override
  Future<IMenuContent> getMenuContent(WindowUI ui, int index);

  @override
  String getMenuId();

  @override
  Future<List<String>> getMenus(WindowUI ui);

  @override
  bool get isPlayable;

  @override
  bool get isResetPlaylist;
  
  bool get isDjMenu => true;
}