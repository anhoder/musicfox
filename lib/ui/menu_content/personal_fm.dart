import 'package:colorful_cmd/component.dart';
import 'package:colorful_cmd/utils.dart';
import 'package:musicfox/ui/bottom_out_content.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';
import 'package:musicfox/utils/function.dart';
import 'package:netease_music_request/request.dart';

class PersonalFm implements IMenuContent {
  List _songs;

  @override
  bool get isPlayable => true;

  @override
  bool get isResetPlaylist => true;

  @override
  Future<BottomOutContent> bottomOut(WindowUI ui) async {
    var song = Song();
    Map response = await song.getPersonalFMSongs();
    response = validateResponse(ui, response);
    if (response == null) return null;

    var songs = response.containsKey('data') ? response['data'] : [];

    var res = getListFromSongs(songs);

    return BottomOutContent(res, songs);
  }

  @override
  Future<String> getContent(WindowUI ui) => null;

  @override
  Future<IMenuContent> getMenuContent(WindowUI ui, int index) => null;

  @override
  Future<List<String>> getMenus(WindowUI ui) async {
    if (_songs == null || _songs.isEmpty) {
      var song = Song();
      Map response = await song.getPersonalFMSongs();
      response = validateResponse(ui, response);
      if (response == null) return null;

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
        if (artistName != '<>') name = '${name} ' + ColorText().gray(artistName).toString();
      }
      res.add(name);
    });

    return Future.value(res);
  }

  @override
  String getMenuId() => 'PersonalFm()';

}