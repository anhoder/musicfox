import 'package:musicfox/ui/bottom_out_content.dart';
import 'package:colorful_cmd/component.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';
import 'package:musicfox/utils/function.dart';
import 'package:netease_music_request/request.dart';

class DjProgram implements IMenuContent {
  int djId;
  List _programs;

  DjProgram(int djId) {
    if (this.djId != djId) _programs = null;
    this.djId = djId;
  }

  @override
  Future<BottomOutContent> bottomOut(WindowUI ui) => null;

  @override
  Future<String> getContent(WindowUI ui) => null;

  @override
  Future<IMenuContent> getMenuContent(WindowUI ui, int index) => null;

  @override
  String getMenuId() => 'DjProgram(${djId})';

  @override
  Future<List<String>> getMenus(WindowUI ui) async {
    if (_programs == null || _programs.isEmpty) {
      var dj = Dj();
      Map response = await dj.getDjPrograms(djId);
      response = validateResponse(ui, response);
      if (response == null) return null;
      
      List programs = response.containsKey('programs') ? response['programs'] : [];
      _programs = programs.map((item) => item['mainSong'] ?? {}).toList();
    }

    ui.pageData = _programs;

    var res = getListFromSongs(_programs);

    return Future.value(res);
  }

  @override
  bool get isPlayable => true;

  @override
  bool get isResetPlaylist => false;
  
}