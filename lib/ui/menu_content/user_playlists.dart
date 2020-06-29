import 'package:colorful_cmd/component.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';
import 'package:musicfox/utils/function.dart';
import 'package:netease_music_request/request.dart';

class UserPlaylists implements IMenuContent {

  static int _userId;
  static List _playlists;

  UserPlaylists(int userId) {
    if (_userId != userId) _playlists = null;
    _userId = userId;
  }

  @override
  bool get isPlayable => false;

  @override
  Future<String> getContent(WindowUI ui) {
    return Future.value('');
  }

  @override
  Future<IMenuContent> getMenuContent(WindowUI ui, int index) {
    return Future.value();
  }

  @override
  Future<List<String>> getMenus(WindowUI ui) async {
    if (_userId == null) return [];
    if (_playlists == null || _playlists.isEmpty) {
      await checkLogin(ui);
      
      var playlist = Playlist();
      Map response = await playlist.gteUserPlaylists(_userId);
      response = validateResponse(response);

      // _playlist = response.containsKey('recommend') ? response['recommend'] : [];
    }
  }
  
}