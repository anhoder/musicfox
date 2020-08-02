import 'package:musicfox/ui/bottom_out_content.dart';
import 'package:colorful_cmd/component.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';
import 'package:musicfox/utils/function.dart';
import 'package:netease_music_request/request.dart';

class DjProgram24Rank implements IMenuContent {
  List _programs;

  @override
  Future<BottomOutContent> bottomOut(WindowUI ui) => null;

  @override
  Future<String> getContent(WindowUI ui) => null;

  @override
  Future<IMenuContent> getMenuContent(WindowUI ui, int index) => null;

  @override
  String getMenuId() => 'DjProgram24Rank()';

  @override
  Future<List<String>> getMenus(WindowUI ui) async {
    if (_programs == null || _programs.isEmpty) {
      var dj = Dj();
      Map response = await dj.getProgram24Rank();
      response = validateResponse(ui, response);
      if (response == null) return null;
      
      List programs = response['data']['list'] ?? [];
      _programs = programs.map((item) => item['program']['mainSong'] ?? {}).toList();
    }

    ui.pageData = _programs;

    var res = getListFromSongs(_programs);

    return Future.value(res);
  }

  @override
  bool get isPlayable => true;

  @override
  bool get isResetPlaylist => false;
  
  @override
  bool get isDjMenu => false;
}