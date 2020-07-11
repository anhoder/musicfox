import 'package:musicfox/ui/bottom_out_content.dart';
import 'package:colorful_cmd/component.dart';
import 'package:musicfox/ui/login.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';
import 'package:musicfox/utils/function.dart';
import 'package:netease_music_request/request.dart' as request;

class Cloud implements IMenuContent {
  @override
  Future<BottomOutContent> bottomOut(WindowUI ui) => null;

  @override
  Future<String> getContent(WindowUI ui) => null;

  @override
  Future<IMenuContent> getMenuContent(WindowUI ui, int index) => null;

  @override
  String getMenuId() => 'Cloud()';

  @override
  Future<List<String>> getMenus(WindowUI ui) async {
    var loginStatus = await checkLogin(ui);
    if (!loginStatus) return null;

    var artist = request.Cloud();
    Map response = await artist.getCloud();
    response = validateResponse(ui, response);
    if (response == null) return null;
    if (response['code'] == 301) {
      loginStatus = await login(ui);
      if (!loginStatus) return null;
      return getMenus(ui);
    }

    List cloud = response.containsKey('data') ? response['data'] : [];

    var songs = [];
    cloud.forEach((item) {
      var it = {};
      if (item.containsKey('simpleSong')) {
        it = item['simpleSong'];
      } else {
        it = {
          'artists': [{'name': item['artist']}],
          'duration': 599,
        };
      }
      it['id'] = item['songId'];
      it['name'] = item['songName'];
      songs.add(it);
    });

    ui.pageData = songs;

    return getListFromSongs(songs);
  }

  @override
  bool get isPlayable => true;

  @override
  bool get isResetPlaylist => false;
  
}