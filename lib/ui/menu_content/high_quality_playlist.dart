import 'package:musicfox/ui/bottom_out_content.dart';
import 'package:colorful_cmd/component.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';
import 'package:musicfox/ui/menu_content/playlist_songs.dart';
import 'package:musicfox/utils/function.dart';
import 'package:netease_music_request/request.dart';

class HighQualityPlaylist implements IMenuContent {
  @override
  Future<BottomOutContent> bottomOut(WindowUI ui) => null;

  @override
  Future<String> getContent(WindowUI ui) => null;

  @override
  Future<IMenuContent> getMenuContent(WindowUI ui, int index) {
    if (ui.pageData.length - 1 < index || !ui.pageData[index].containsKey('id')) return null;
    return Future.value(PlaylistSongs(ui.pageData[index]['id']));
  }

  @override
  String getMenuId() => 'HighQualityPlaylist()';

  @override
  Future<List<String>> getMenus(WindowUI ui) async {
    var playlist = Playlist();
    Map response = await playlist.getQualityPlaylists();
    response = validateResponse(ui, response);
    if (response == null) return null;

    var playlists = response.containsKey('playlists') ? response['playlists'] : [];
    ui.pageData = playlists;

    return getListFromPlaylists(playlists);
  }

  @override
  bool get isPlayable => false;

  @override
  bool get isResetPlaylist => false;
  
}