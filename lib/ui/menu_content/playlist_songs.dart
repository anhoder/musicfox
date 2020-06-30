import 'package:colorful_cmd/component.dart';
import 'package:colorful_cmd/utils.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';
import 'package:musicfox/utils/function.dart';
import 'package:netease_music_request/request.dart';

class PlaylistSongs implements IMenuContent {

  static int _playlistId;
  static List _songs;

  @override
  bool get isPlayable => true;

  PlaylistSongs(int playlistId) {
    if (_playlistId != playlistId) _songs = null;
    _playlistId = playlistId;
  }

  @override
  Future<String> getContent(WindowUI ui) => Future.value('');

  @override
  Future<IMenuContent> getMenuContent(WindowUI ui, int index) => Future.value();

  @override
  Future<List<String>> getMenus(WindowUI ui) async {
    if (_playlistId == null) return [];
    if (_songs == null || _songs.isEmpty) {
      var playlist = Playlist();
      Map response = await playlist.getPlaylistDetail(_playlistId);
      response = validateResponse(response);

      List trackIds = response.containsKey('playlist') ? (response['playlist'].containsKey('trackIds') ? response['playlist']['trackIds'] : []) : [];
      var songIds = <int>[];
      trackIds.forEach((item) {
        songIds.add(item['id']);
      });

      var song = Song();
      var songResponse = await song.getSongDetail(songIds);
      songResponse = validateResponse(songResponse);
      _songs = songResponse.containsKey('songs') ? songResponse['songs'] : [];
    }
    ui.pageData = _songs;

    var res = <String>[];
    _songs.forEach((item) {
      var name = '';
      if (item.containsKey('name')) {
        var artistName = '';
        name = item['name'];
        if (item.containsKey('ar')) {
          item['ar'].forEach((artist) {
            if (artist.containsKey('name')) {
              artistName = artistName == '' ? artist['name'] : '${artistName},${artist['name']}';
            }
          });
        }
        artistName = '<${artistName}>';
        name = '${name} ' + ColorText().gray(artistName).toString();
      }
      res.add(name);
    });

    return Future.value(res);
  }

  @override
  Future<List<String>> bottomOut(WindowUI ui) => null;
  
}