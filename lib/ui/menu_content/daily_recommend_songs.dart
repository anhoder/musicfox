import 'package:colorful_cmd/component.dart';
import 'package:musicfox/cache/i_cache.dart';
import 'package:musicfox/ui/login.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';
import 'package:netease_music_request/request.dart';

class DailyRecommendSongs implements IMenuContent{
  @override
  Future<String> getContent(WindowUI ui) {
    return Future.value('');
  }

  @override
  Future<List<String>> getMenus(WindowUI ui) async {
    var cache = CacheFactory.produce();
    var user = cache.get('user');
    if (user == null) await login(ui);
    
    var song = Song();
    var response = await song.getRecommendSongs();
    cache.set('song', response);

    return Future.value(['1243']);
  }

  @override
  Future<List<IMenuContent>> getMenuContent(WindowUI ui) {
    return Future.value([DailyRecommendSongs()]);
  }

}