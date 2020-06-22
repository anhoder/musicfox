import 'package:colorful_cmd/component.dart';
import 'package:colorful_cmd/utils.dart';
import 'package:musicfox/cache/i_cache.dart';
import 'package:musicfox/ui/login.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';
import 'package:musicfox/utils/function.dart';
import 'package:netease_music_request/request.dart';

class DailyRecommendSongs implements IMenuContent{
  @override
  bool get isPlaylist => true;

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
    Map response = await song.getRecommendSongs();
    response = validateResponse(response);

    List list = response.containsKey('recommend') ? response['recommend'] : [];
    ui.pageData = list;

    var res = <String>[];
    list.forEach((item) {
      var name = '';
      if (item.containsKey('name')) {
        var artistName = '';
        name = item['name'];
        if (item.containsKey('artists')) {
          item['artists'].forEach((artist) {
            if (artist.containsKey('name')) {
              artistName = artistName == '' ? artist['name'] : '${artistName},${artist['name']}';
            }
          });
        }
        artistName = '<${artistName}>';
        name = '${name} ' + ColorText().gray(artistName).toString();
      }
      res.add(name);
    });

    return Future.value(res);
  }

  @override
  Future<List<IMenuContent>> getMenuContent(WindowUI ui) {
    return Future.value([]);
  }

}