import 'package:musicfox/ui/menu_content/album_content.dart';
import 'package:musicfox/ui/bottom_out_content.dart';
import 'package:colorful_cmd/component.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';
import 'package:musicfox/utils/function.dart';
import 'package:netease_music_request/request.dart';

class NewAlbums implements IMenuContent {
  List _albums;

  @override
  Future<BottomOutContent> bottomOut(WindowUI ui) => null;

  @override
  Future<String> getContent(WindowUI ui) => null;

  @override
  Future<IMenuContent> getMenuContent(WindowUI ui, int index) async {
    if (ui.pageData.length - 1 < index || !ui.pageData[index].containsKey('id')) return null;
    return Future.value(AlbumContent(ui.pageData[index]['id']));
  }

  @override
  Future<List<String>> getMenus(WindowUI ui) async {
    if (_albums == null) {
      var album = Album();
      Map response = await album.getNewAlbums();
      response = validateResponse(ui, response);

      _albums = response.containsKey('albums') ? response['albums'] : [];
    }
    ui.pageData = _albums;

    var res = getListFromAlbums(_albums);

    return res;
  }

  @override
  bool get isPlayable => false;

  @override
  bool get isResetPlaylist => false;

  @override
  String getMenuId() => 'NewAlbums()';
  
}