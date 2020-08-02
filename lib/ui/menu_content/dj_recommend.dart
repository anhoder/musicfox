import 'package:musicfox/ui/bottom_out_content.dart';
import 'package:colorful_cmd/component.dart';
import 'package:musicfox/ui/menu_content/dj_program.dart';
import 'package:musicfox/ui/menu_content/i_dj_menu_content.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';
import 'package:musicfox/utils/function.dart';
import 'package:netease_music_request/request.dart';

class DjRecommend extends IDjMenuContent {

  List _djList;

  @override
  Future<BottomOutContent> bottomOut(WindowUI ui) => null;

  @override
  Future<String> getContent(WindowUI ui) => null;

  @override
  Future<IMenuContent> getMenuContent(WindowUI ui, int index) {
    if (ui.pageData.length - 1 < index || !ui.pageData[index].containsKey('id')) return null;
    return Future.value(DjProgram(ui.pageData[index]['id']));
  }

  @override
  String getMenuId() => 'DjRecommend()';

  @override
  Future<List<String>> getMenus(WindowUI ui) async {
    if (_djList == null || _djList.isEmpty) {
      var dj = Dj();
      Map response = await dj.getRecommendDjs();
      response = validateResponse(ui, response);
      if (response == null) return null;

      _djList = response.containsKey('djRadios') ? response['djRadios'] : [];
    }

    ui.pageData = _djList;

    var res = getListFromDjs(_djList);

    return Future.value(res);
  }

  @override
  bool get isPlayable => false;

  @override
  bool get isResetPlaylist => false;
  
}