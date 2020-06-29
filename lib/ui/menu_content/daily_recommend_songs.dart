import 'package:colorful_cmd/component.dart';
import 'package:colorful_cmd/utils.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';
import 'package:musicfox/utils/function.dart';
import 'package:netease_music_request/request.dart';

class DailyRecommendSongs implements IMenuContent{
  List _songs;

  @override
  bool get isPlayable => true;

  @override
  Future<String> getContent(WindowUI ui) {
    return Future.value(''); 
  }

  @override
  Future<List<String>> getMenus(WindowUI ui) async {
    if (_songs == null || _songs.isEmpty) {
      await checkLogin(ui);
      
      var song = Song();
      Map response = await song.getRecommendSongs();
      response = validateResponse(response);

      _songs = response.containsKey('recommend') ? response['recommend'] : [];
    }
    ui.pageData = _songs;

    var res = <String>[];
    _songs.forEach((item) {
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
  Future<IMenuContent> getMenuContent(WindowUI ui, int index) {
    return Future.value();
  }

}