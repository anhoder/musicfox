import 'package:colorful_cmd/command.dart';
import 'package:colorful_cmd/logger.dart';
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
    _ui.window.display();
    return false;
  }
}