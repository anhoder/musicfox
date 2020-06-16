import 'package:colorful_cmd/component.dart';
import 'package:musicfox/ui/login.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';

class DailyRecommendSongs implements IMenuContent{
  @override
  Future<String> getContent(WindowUI ui) {
    return Future.value('');
  }

  @override
  Future<List<String>> getMenus(WindowUI ui) async {
    await login(ui);
    return Future.value(['1243']);
  }

  @override
  Future<List<IMenuContent>> getMenuContent(WindowUI ui) {
    return Future.value([DailyRecommendSongs()]);
  }

}