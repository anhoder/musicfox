import 'package:musicfox/ui/bottom_out_content.dart';
import 'package:colorful_cmd/component.dart';
import 'package:musicfox/ui/menu_content/dj_of_cat.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';
import 'package:musicfox/utils/function.dart';
import 'package:netease_music_request/request.dart';

class DjCat extends IMenuContent {

  List _djCatList;

  @override
  Future<BottomOutContent> bottomOut(WindowUI ui) => null;

  @override
  Future<String> getContent(WindowUI ui) => null;

  @override
  Future<IMenuContent> getMenuContent(WindowUI ui, int index) {
    if (ui.pageData.length - 1 < index || !ui.pageData[index].containsKey('id')) return null;
    return Future.value(DjOfCat(ui.pageData[index]['id']));
  }

  @override
  String getMenuId() => 'DjCat()';

  @override
  Future<List<String>> getMenus(WindowUI ui) async {
    if (_djCatList == null || _djCatList.isEmpty) {
      var dj = Dj();
      Map response = await dj.getDjCategories();
      response = validateResponse(ui, response);
      if (response == null) return null;

      _djCatList = response.containsKey('categories') ? response['categories'] : [];
    }

    ui.pageData = _djCatList;

    var res = getListFromDjCats(_djCatList);

    return Future.value(res);
  }

  @override
  bool get isPlayable => false;

  @override
  bool get isResetPlaylist => false;

  @override
  bool get isDjMenu => false;
  
}