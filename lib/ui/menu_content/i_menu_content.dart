import 'package:colorful_cmd/component.dart';
import 'package:musicfox/ui/bottom_out_content.dart';

abstract class IMenuContent {

  bool get isPlayable;
  bool get isResetPlaylist;

  Future<List<String>> getMenus(WindowUI ui);

  Future<String> getContent(WindowUI ui);

  Future<IMenuContent> getMenuContent(WindowUI ui, int index);

  Future<BottomOutContent> bottomOut(WindowUI ui);
}