import 'package:colorful_cmd/component.dart';

abstract class IMenuContent {

  Future<List<String>> getMenus(WindowUI ui);

  Future<String> getContent(WindowUI ui);

  Future<IMenuContent> getMenuContent(WindowUI ui, int index);
}