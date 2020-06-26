import 'dart:io';

import 'package:colorful_cmd/command.dart';
import 'package:colorful_cmd/logger.dart';
import 'package:musicfox/exception/response_exception.dart';
import 'package:musicfox/ui/main_ui.dart';

class Player extends ICmd {
  @override
  String get name => 'player';

  @override
  String get description => 'Musicfox mp3 player';

  final MainUI _ui;

  @override
  List<Flag> get flags => null;

  @override
  List<ILogHandler> get logHandlers => null;

  @override
  List<Option> get options => null;
  
  Player(): _ui = MainUI();

  @override
  bool run() {
    try {
      _ui.display();
      return false;
    } on SocketException {
      _ui.error('网络错误，请检查网络~');
      return false;
    } on ResponseException catch (e) {
      _ui.error(e.toString());
      return false;
    } catch (e) {
      rethrow;
    }
  }
}