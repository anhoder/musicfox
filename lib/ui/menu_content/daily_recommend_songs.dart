import 'dart:io';

import 'package:colorful_cmd/component.dart';
import 'package:musicfox/ui/bottom_out_content.dart';
import 'package:musicfox/ui/login.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';
import 'package:musicfox/utils/function.dart';
import 'package:netease_music_request/request.dart';

class DailyRecommendSongs implements IMenuContent{
  List _songs;

  @override
  bool get isPlayable => true;

  @override
  bool get isResetPlaylist => false;

  @override
  Future<String> getContent(WindowUI ui) => Future.value(''); 

  @override
  Future<List<String>> getMenus(WindowUI ui) async {
    if (_songs == null || _songs.isEmpty) {
      await checkLogin(ui);
      
      var song = Song();
      Map response = await song.getRecommendSongs();
      response = validateResponse(ui, response);
      if (response['code'] == 301) {
        await login(ui);
        return getMenus(ui);
      }

      _songs = response.containsKey('recommend') ? response['recommend'] : [];
    }
    ui.pageData = _songs;

    var res = getListFromSongs(_songs);

    return Future.value(res);
  }

  @override
  Future<IMenuContent> getMenuContent(WindowUI ui, int index) => null;

  @override
  Future<BottomOutContent> bottomOut(WindowUI ui) => null;

  @override
  String getMenuId() => 'DailyRecommendSongs()';

}