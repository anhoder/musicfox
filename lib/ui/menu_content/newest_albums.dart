import 'package:colorful_cmd/utils.dart';
import 'package:musicfox/ui/menu_content/album_content.dart';
import 'package:musicfox/ui/menu_content/bottom_out_content.dart';
import 'package:colorful_cmd/component.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';
import 'package:musicfox/utils/function.dart';
import 'package:netease_music_request/request.dart';

class NewestAlbums implements IMenuContent {
  List _albums;

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
  Future<List<String>> getMenus(WindowUI ui) async {
    if (_albums == null || _albums.isEmpty) {
      var album = Album();
      Map response = await album.getHotNewAlbums();
      response = validateResponse(response);

      _albums = response.containsKey('albums') ? response['albums'] : [];
    }
    ui.pageData = _albums;

    var res = <String>[];
    _albums.forEach((album) {
      var name = album.containsKey('name') ? album['name'] : '';
      var artistName = album.containsKey('artist') ? album['artist']['name'] : '';
      artistName = '<${artistName}>';
      name = '${name} ' + ColorText().gray(artistName).toString();

      res.add(name);
    });

    return res;
  }

  @override
  bool get isPlayable => false;

  @override
  bool get isResetPlaylist => false;
  
}