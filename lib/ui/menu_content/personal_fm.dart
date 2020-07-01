import 'package:colorful_cmd/component.dart';
import 'package:colorful_cmd/utils.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';
import 'package:musicfox/utils/function.dart';
import 'package:netease_music_request/request.dart';

class PersonalFm implements IMenuContent {
  List _songs;

  @override
  bool get isPlayable => true;

  @override
  Future<List<String>> bottomOut(WindowUI ui) {
    // TODO: implement bottomOut
    return null;
  }

  @override
  Future<String> getContent(WindowUI ui) => null;

  @override
  Future<IMenuContent> getMenuContent(WindowUI ui, int index) => null;

  @override
  Future<List<String>> getMenus(WindowUI ui) async {
    if (_songs == null || _songs.isEmpty) {
      await checkLogin(ui);
      
      var song = Song();
      Map response = await song.getPersonalFMSongs();
      response = validateResponse(response);

      _songs = response.containsKey('data') ? response['data'] : [];
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

  
}