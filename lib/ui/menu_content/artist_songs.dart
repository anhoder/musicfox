import 'package:musicfox/ui/bottom_out_content.dart';
import 'package:colorful_cmd/component.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';
import 'package:musicfox/utils/function.dart';
import 'package:netease_music_request/request.dart';

class ArtistSongs implements IMenuContent {

  final int _artistId;

  ArtistSongs(this._artistId);

  @override
  Future<BottomOutContent> bottomOut(WindowUI ui) => null;

  @override
  Future<String> getContent(WindowUI ui) => null;

  @override
  Future<IMenuContent> getMenuContent(WindowUI ui, int index) => null;

  @override
  String getMenuId() => 'ArtistSongs(${_artistId})';

  @override
  Future<List<String>> getMenus(WindowUI ui) async {
    var artist = Artist();
    Map response = await artist.getSongs(_artistId);
    response = validateResponse(ui, response);
    if (response == null) return null;

    var songs = response.containsKey('hotSongs') ? response['hotSongs'] : [];
    ui.pageData = songs;

    var res = getListFromSongs(songs);

    return Future.value(res);
  }

  @override
  bool get isPlayable => true;

  @override
  bool get isResetPlaylist => false;
  
}