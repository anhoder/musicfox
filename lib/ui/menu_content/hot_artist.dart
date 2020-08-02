import 'package:musicfox/ui/bottom_out_content.dart';
import 'package:colorful_cmd/component.dart';
import 'package:musicfox/ui/menu_content/artist.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';
import 'package:musicfox/utils/function.dart';
import 'package:netease_music_request/request.dart' as request;

class HotArtist implements IMenuContent {
  @override
  Future<BottomOutContent> bottomOut(WindowUI ui) => null;

  @override
  Future<String> getContent(WindowUI ui) => null;

  @override
  Future<IMenuContent> getMenuContent(WindowUI ui, int index) {
    if (ui.pageData.length - 1 < index || !ui.pageData[index].containsKey('id')) return null;
    return Future.value(Artist(ui.pageData[index]['id']));
  }

  @override
  String getMenuId() => 'HotArtist()';

  @override
  Future<List<String>> getMenus(WindowUI ui) async {
    var artist = request.Artist();
    Map response = await artist.getHotArtists();
    response = validateResponse(ui, response);
    if (response == null) return null;

    var artists = response.containsKey('artists') ? response['artists'] : [];
    ui.pageData = artists;

    return getListFromArtists(artists);
  }

  @override
  bool get isPlayable => false;

  @override
  bool get isResetPlaylist => false;
  
  @override
  bool get isDjMenu => false;
}