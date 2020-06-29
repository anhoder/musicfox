import 'package:colorful_cmd/component.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';
import 'package:musicfox/ui/menu_content/playlist_songs.dart';
import 'package:musicfox/utils/function.dart';
import 'package:netease_music_request/request.dart';

class DailyRecommandPlaylist implements IMenuContent {
  List _playlist;

  @override
  bool get isPlayable => false;

  @override
  Future<String> getContent(WindowUI ui) {
    return Future.value('');
  }

  @override
  Future<IMenuContent> getMenuContent(WindowUI ui, int index) {
    if (ui.pageData.length - 1 < index || !ui.pageData[index].containsKey('id')) return null;
    return Future.value(PlaylistSongs(ui.pageData[index]['id']));
  }

  @override
  Future<List<String>> getMenus(WindowUI ui) async {
    if (_playlist == null || _playlist.isEmpty) {
      await checkLogin(ui);
      
      var playlist = Playlist();
      Map response = await playlist.getDailyRecommendPlaylists();
      response = validateResponse(response);

      _playlist = response.containsKey('recommend') ? response['recommend'] : [];
    }
    ui.pageData = _playlist;

    var res = <String>[];
    _playlist.forEach((item) {
      var name = '';
      if (item.containsKey('name')) {
        name = item['name'];
      }
      res.add(name);
    });

    return Future.value(res);
  }
}