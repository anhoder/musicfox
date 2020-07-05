import 'package:musicfox/ui/bottom_out_content.dart';
import 'package:colorful_cmd/component.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';
import 'package:musicfox/utils/function.dart';
import 'package:netease_music_request/request.dart';

class AlbumContent implements IMenuContent {
  static int _albumId;
  static List _songs;

  AlbumContent(int albumId) {
    if (_albumId != albumId) _songs = null;
    _albumId = albumId;
  }

  @override
  Future<BottomOutContent> bottomOut(WindowUI ui) => null;

  @override
  Future<String> getContent(WindowUI ui) => null;

  @override
  Future<IMenuContent> getMenuContent(WindowUI ui, int index) => null;

  @override
  Future<List<String>> getMenus(WindowUI ui) async {
    if (_albumId == null) return [];
    if (_songs == null) {
      var album = Album();
      Map response = await album.getAlbum(_albumId);
      response = validateResponse(response);

      _songs = response.containsKey('songs') ? response['songs'] : [];
    }
    ui.pageData = _songs;

    var res = getListFromSongs(_songs);

    return res;
  }

  @override
  bool get isPlayable => true;

  @override
  bool get isResetPlaylist => false;
  
}