import 'package:musicfox/ui/bottom_out_content.dart';
import 'package:colorful_cmd/component.dart';
import 'package:musicfox/ui/menu_content/album_content.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';
import 'package:musicfox/utils/function.dart';
import 'package:netease_music_request/request.dart';

class ArtistAlbums implements IMenuContent {

  final int _artistId;

  ArtistAlbums(this._artistId);

  @override
  Future<BottomOutContent> bottomOut(WindowUI ui) => null;

  @override
  Future<String> getContent(WindowUI ui) => null;

  @override
  Future<IMenuContent> getMenuContent(WindowUI ui, int index) {
    if (ui.pageData.length - 1 < index || !ui.pageData[index].containsKey('id')) return null;
    return Future.value(AlbumContent(ui.pageData[index]['id']));
  }

  @override
  String getMenuId() => 'ArtistAlbums(${_artistId})';

  @override
  Future<List<String>> getMenus(WindowUI ui) async {
    var artist = Artist();
    Map response = await artist.getAlbums(_artistId);
    response = validateResponse(ui, response);

    var albums = response.containsKey('hotAlbums') ? response['hotAlbums'] : [];
    ui.pageData = albums;

    var res = getListFromSongs(albums);

    return Future.value(res);
  }

  @override
  bool get isPlayable => false;

  @override
  bool get isResetPlaylist => false;
  
}